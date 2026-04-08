---
name: schema-fiscal-espanol-supabase
description: >
  Schema completo de base de datos Supabase para aplicaciones de gestion fiscal
  en Espana. Incluye 11 tablas con dominio fiscal espanol: datos fiscales (NIF/CIF,
  regimen, IAE), facturas (emitidas/recibidas con IVA/IRPF), modelos fiscales
  (303, 130, 200, 347, 111), calendario fiscal con recurrencia, avisos/alertas,
  historicos anuales, simulaciones de impuestos, informes, integraciones (AEAT),
  preferencias. RLS user-scoped en todas las tablas. 3 views para KPIs de dashboard.
  Storage bucket para documentos. Basado en AsesIA Fiscal (Next.js 15 + Supabase).
  Usar cuando el usuario necesite: app fiscal, gestion de facturas, modelos
  tributarios, IVA, IRPF, autonomos, SL, calendario fiscal, AEAT, contabilidad.
triggers:
  - "app fiscal"
  - "gestion facturas"
  - "modelos tributarios"
  - "IVA IRPF"
  - "autonomos"
  - "schema fiscal"
  - "calendario fiscal"
  - "AEAT"
  - "asesor fiscal"
type: blueprint
---

# Schema Fiscal Espanol para Supabase

## Modelo de Datos

```
profiles ─────┬── datos_fiscales (NIF, regimen, IAE)
              ├── facturas (emitidas/recibidas, IVA, IRPF)
              ├── modelos_fiscales (303, 130, 200, 347, 111)
              │     └── calendario_fiscal (obligaciones, recordatorios)
              ├── avisos (alertas urgentes/warning/info)
              ├── historicos (resumen anual: ingresos, gastos, impuestos)
              ├── simulaciones (escenarios what-if de impuestos)
              ├── informes (trimestrales, anuales, por modelo)
              ├── integraciones (AEAT, bancos, Google Calendar)
              └── preferencias (tema, idioma, notificaciones)
```

## Enums del Dominio Fiscal Espanol

| Enum | Valores | Uso |
|------|---------|-----|
| factura_tipo | emitida, recibida | Tipo de factura |
| factura_estado | pendiente, pagada, vencida, anulada | Estado de cobro/pago |
| modelo_estado | pendiente, en_proceso, presentado, pagado | Estado de presentacion |
| evento_tipo | obligacion, recordatorio, pago, presentacion, otro | Tipo de evento fiscal |
| aviso_tipo | urgente, warning, info, success | Severidad de alerta |
| aviso_categoria | plazo, pago, factura, sistema, ia | Origen de la alerta |
| informe_estado | borrador, generado, enviado, presentado | Estado del informe |

## Tablas Principales

### datos_fiscales — Identidad fiscal del contribuyente
- `nif_cif` TEXT NOT NULL — Identificador fiscal (NIF personas fisicas, CIF sociedades)
- `regimen_fiscal` TEXT DEFAULT 'autonomo' — Regimen tributario
- `actividad_iae` TEXT — Codigo IAE (clasificacion de actividades economicas)
- `domicilio_fiscal` TEXT — Direccion fiscal registrada
- `gestoria` TEXT — Gestoria/asesoria asociada

### facturas — Facturacion con calculo IVA/IRPF
- `tipo` factura_tipo — emitida (ventas) o recibida (compras)
- `base_imponible` DECIMAL(12,2) — Base antes de impuestos
- `tipo_iva` DECIMAL(5,2) DEFAULT 21 — Tipo de IVA aplicado (%)
- `cuota_iva` DECIMAL(12,2) — Importe del IVA
- `tipo_irpf` DECIMAL(5,2) DEFAULT 0 — Retencion IRPF (%)
- `cuota_irpf` DECIMAL(12,2) — Importe de la retencion
- `total` DECIMAL(12,2) — Base + IVA - IRPF

### modelos_fiscales — Declaraciones tributarias
- `modelo` TEXT — '303' (IVA trimestral), '130' (IRPF fraccionado), '200' (IS), '347' (operaciones >3.005€), '111' (retenciones)
- `periodo` TEXT — '1T', '2T', '3T', '4T', 'Anual'
- `ejercicio` INTEGER — Ano fiscal
- `base_imponible`, `cuota`, `resultado` — Importes de la declaracion
- `fecha_limite` DATE — Plazo maximo de presentacion
- `numero_justificante` TEXT — Numero de recibo de la AEAT

### simulaciones — Calculadora de impuestos what-if
- `cuota_autonomos` DECIMAL DEFAULT 314 — Cuota mensual de autonomos
- `resultado_iva`, `resultado_irpf`, `resultado_sociedades`, `resultado_seg_social` — Desglose
- `resultado_total_impuestos`, `resultado_beneficio_neto` — Totales
- `parametros` JSONB — Parametros adicionales flexibles

### historicos — Resumen fiscal anual
- `ingresos_totales`, `gastos_totales`, `beneficio_neto` — P&L
- `irpf_pagado`, `iva_pagado`, `sociedades_pagado`, `seg_social_pagado` — Desglose impositivo

## Views para Dashboard

### v_resumen_ejercicio
Ingresos, gastos, IVA repercutido/soportado, facturas emitidas/recibidas por ejercicio fiscal.

### v_proximos_vencimientos
Modelos fiscales pendientes con dias restantes hasta fecha limite. Ordenados por urgencia.

### v_avisos_pendientes
Contadores de alertas: urgentes, pendientes de leer, resueltos hoy, plazos en proximos 7 dias.

## Schema SQL Completo

```sql
-- Ejecutar en Supabase SQL Editor

-- 1. PROFILES
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT, phone TEXT, role TEXT DEFAULT 'admin',
  avatar_url TEXT, created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. DATOS FISCALES
CREATE TABLE public.datos_fiscales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  nif_cif TEXT NOT NULL,
  regimen_fiscal TEXT NOT NULL DEFAULT 'autonomo',
  actividad_iae TEXT, domicilio_fiscal TEXT, gestoria TEXT,
  fecha_alta TIMESTAMPTZ DEFAULT NOW(), verificado BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 3. FACTURAS
CREATE TYPE public.factura_tipo AS ENUM ('emitida', 'recibida');
CREATE TYPE public.factura_estado AS ENUM ('pendiente', 'pagada', 'vencida', 'anulada');
CREATE TABLE public.facturas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  numero TEXT NOT NULL, tipo public.factura_tipo NOT NULL,
  estado public.factura_estado NOT NULL DEFAULT 'pendiente',
  cliente_proveedor TEXT NOT NULL, concepto TEXT,
  base_imponible DECIMAL(12,2) NOT NULL DEFAULT 0,
  tipo_iva DECIMAL(5,2) NOT NULL DEFAULT 21,
  cuota_iva DECIMAL(12,2) NOT NULL DEFAULT 0,
  tipo_irpf DECIMAL(5,2) DEFAULT 0,
  cuota_irpf DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) NOT NULL DEFAULT 0,
  fecha_emision DATE NOT NULL, fecha_vencimiento DATE, fecha_cobro_pago DATE,
  notas TEXT, archivo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. MODELOS FISCALES
CREATE TYPE public.modelo_estado AS ENUM ('pendiente', 'en_proceso', 'presentado', 'pagado');
CREATE TABLE public.modelos_fiscales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  modelo TEXT NOT NULL, periodo TEXT NOT NULL, ejercicio INTEGER NOT NULL,
  estado public.modelo_estado NOT NULL DEFAULT 'pendiente',
  base_imponible DECIMAL(12,2) DEFAULT 0,
  cuota DECIMAL(12,2) DEFAULT 0, resultado DECIMAL(12,2) DEFAULT 0,
  fecha_limite DATE NOT NULL, fecha_presentacion DATE, fecha_pago DATE,
  numero_justificante TEXT, notas TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CALENDARIO FISCAL
CREATE TYPE public.evento_tipo AS ENUM ('obligacion', 'recordatorio', 'pago', 'presentacion', 'otro');
CREATE TABLE public.calendario_fiscal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL, descripcion TEXT,
  tipo public.evento_tipo NOT NULL DEFAULT 'obligacion',
  fecha DATE NOT NULL, fecha_fin DATE,
  modelo_id UUID REFERENCES public.modelos_fiscales(id) ON DELETE SET NULL,
  completado BOOLEAN DEFAULT FALSE,
  recurrente BOOLEAN DEFAULT FALSE, periodicidad TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. AVISOS
CREATE TYPE public.aviso_tipo AS ENUM ('urgente', 'warning', 'info', 'success');
CREATE TYPE public.aviso_categoria AS ENUM ('plazo', 'pago', 'factura', 'sistema', 'ia');
CREATE TABLE public.avisos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL, descripcion TEXT,
  tipo public.aviso_tipo NOT NULL DEFAULT 'info',
  categoria public.aviso_categoria NOT NULL DEFAULT 'sistema',
  leido BOOLEAN DEFAULT FALSE, accion_url TEXT,
  fecha_vencimiento DATE, dias_restantes INTEGER, importe DECIMAL(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. HISTORICOS
CREATE TABLE public.historicos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  ejercicio INTEGER NOT NULL,
  ingresos_totales DECIMAL(14,2) DEFAULT 0,
  gastos_totales DECIMAL(14,2) DEFAULT 0,
  beneficio_neto DECIMAL(14,2) DEFAULT 0,
  impuestos_pagados DECIMAL(14,2) DEFAULT 0,
  irpf_pagado DECIMAL(14,2) DEFAULT 0, iva_pagado DECIMAL(14,2) DEFAULT 0,
  sociedades_pagado DECIMAL(14,2) DEFAULT 0, seg_social_pagado DECIMAL(14,2) DEFAULT 0,
  num_facturas_emitidas INTEGER DEFAULT 0, num_facturas_recibidas INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, ejercicio)
);

-- 8. SIMULACIONES
CREATE TABLE public.simulaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL DEFAULT 'Simulacion',
  regimen TEXT NOT NULL, ingresos DECIMAL(14,2) DEFAULT 0, gastos DECIMAL(14,2) DEFAULT 0,
  tipo_iva DECIMAL(5,2) DEFAULT 21, tipo_irpf DECIMAL(5,2) DEFAULT 20,
  cuota_autonomos DECIMAL(10,2) DEFAULT 314,
  resultado_iva DECIMAL(14,2) DEFAULT 0, resultado_irpf DECIMAL(14,2) DEFAULT 0,
  resultado_sociedades DECIMAL(14,2) DEFAULT 0, resultado_seg_social DECIMAL(14,2) DEFAULT 0,
  resultado_total_impuestos DECIMAL(14,2) DEFAULT 0,
  resultado_beneficio_neto DECIMAL(14,2) DEFAULT 0,
  parametros JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. INFORMES
CREATE TYPE public.informe_estado AS ENUM ('borrador', 'generado', 'enviado', 'presentado');
CREATE TABLE public.informes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL, tipo TEXT NOT NULL,
  periodo TEXT, ejercicio INTEGER,
  estado public.informe_estado NOT NULL DEFAULT 'borrador',
  archivo_url TEXT, enviado_gestoria BOOLEAN DEFAULT FALSE, fecha_envio DATE, notas TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10-11. INTEGRACIONES + PREFERENCIAS (ver schema completo en referencia)

-- RLS en TODAS las tablas: auth.uid() = user_id
-- Indices en: facturas(user_id, fecha_emision, estado), modelos(user_id, fecha_limite),
--             calendario(user_id, fecha), avisos(user_id, leido, tipo)

-- VIEWS
-- v_resumen_ejercicio: P&L por ano con IVA repercutido/soportado
-- v_proximos_vencimientos: Modelos pendientes con dias restantes
-- v_avisos_pendientes: Contadores de alertas por categoria

-- STORAGE: bucket 'documentos' con RLS por user_id
```

## Modelos Tributarios Espanoles Cubiertos

| Modelo | Nombre | Periodicidad | Plazo |
|--------|--------|-------------|-------|
| 303 | Declaracion IVA | Trimestral | 20 abril/julio/octubre, 30 enero |
| 130 | Pago fraccionado IRPF | Trimestral | Mismo que 303 |
| 200 | Impuesto de Sociedades | Anual | 25 julio |
| 347 | Operaciones con terceros >3.005€ | Anual | Febrero |
| 111 | Retenciones IRPF | Mensual/Trimestral | 20 de cada mes/trimestre |
| 390 | Resumen anual IVA | Anual | 30 enero |
