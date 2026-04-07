---
name: rd-214-2025-cooperativas
description: Sistema experto en análisis de cumplimiento del Real Decreto 214/2025 para cooperativas españolas. Determina obligaciones de cálculo de huella de carbono, planes de reducción, requisitos de compensación y aplicabilidad de la doctrina ICAC sobre información no financiera. Especializado en interpretación jurídica de umbrales económicos, alcances de emisiones y proyectos de absorción MITECO.
---

# Real Decreto 214/2025 - Análisis de Cumplimiento para Cooperativas

## 📋 Índice de Contenidos

1. [Objetivo y Alcance](#objetivo-y-alcance)
2. [Cuándo Usar Esta Skill](#cuándo-usar-esta-skill)
3. [Marco Normativo](#marco-normativo)
4. [Workflow de Análisis](#workflow-de-análisis)
5. [Determinación de Aplicabilidad](#determinación-de-aplicabilidad)
6. [Obligaciones de Cumplimiento](#obligaciones-de-cumplimiento)
7. [Compensación de Emisiones](#compensación-de-emisiones)
8. [Casos de Uso y Ejemplos](#casos-de-uso-y-ejemplos)
9. [Referencias Técnicas](#referencias-técnicas)

---

## 1. Objetivo y Alcance

### 1.1 Propósito

Esta skill proporciona análisis técnico-jurídico especializado sobre la aplicabilidad del **Real Decreto 214/2025, de 18 de marzo** a cooperativas españolas, resolviendo la controversia sobre su inclusión mediante la interpretación de la doctrina del ICAC (Consulta 2 BOICAC 133/2023).

### 1.2 Capacidades Clave

✅ **Determinar aplicabilidad** a cooperativas según umbrales económicos  
✅ **Calcular obligaciones** de huella de carbono (alcances 1, 2 y 3)  
✅ **Validar planes de reducción** a 5 años con medidas concretas  
✅ **Evaluar opciones de compensación** con créditos MITECO  
✅ **Aplicar doctrina ICAC** sobre información no financiera  
✅ **Calcular plazos de cumplimiento** para ejercicio 2025-2026  

### 1.3 Límites

❌ No sustituye asesoramiento jurídico profesional  
❌ No calcula directamente la huella de carbono (usar `forest-carbon-calculator`)  
❌ No genera documentación de cumplimiento (requiere verificador ENAC)  

---

## 2. Cuándo Usar Esta Skill

### 2.1 Triggers Principales

**Usa esta skill cuando el usuario:**

- Mencione "Real Decreto 214/2025", "RD 214/2025", "huella de carbono obligatoria"
- Pregunte si una cooperativa está afectada por obligaciones de carbono
- Solicite análisis de umbrales económicos para cooperativas
- Necesite entender obligaciones de información no financiera
- Pregunte sobre compensación de emisiones con créditos MITECO
- Mencione "ICAC", "BOICAC 133/2023", "Consulta 2"
- Pregunte sobre alcances 1, 2 y 3 de emisiones GEI

### 2.2 Palabras Clave

`cooperativa`, `huella de carbono`, `RD 214/2025`, `MITECO`, `información no financiera`, `ICAC`, `créditos de carbono`, `proyectos de absorción`, `planes de reducción`, `alcance 1`, `alcance 2`, `alcance 3`, `ENAC`, `verificación`

### 2.3 Contextos de Aplicación

1. **Due Diligence Regulatorio**: Evaluar cumplimiento normativo de cooperativas target
2. **Planificación Estratégica**: Determinar obligaciones futuras para cooperativas
3. **Estructuración Financiera**: Calcular costes de cumplimiento en business plans
4. **Consultoría Legal**: Fundamentar aplicabilidad del RD a cooperativas
5. **Proyectos de Carbono**: Validar elegibilidad para compensación MITECO

---

## 3. Marco Normativo

### 3.1 Entrada en Vigor

**Fecha clave:** 12 de junio de 2025  
**Ejercicio afectado:** 2025 (reporte en 2026)  
**Deroga:** Real Decreto 163/2014, de 14 de marzo

### 3.2 Novedad Fundamental

> **Primera norma jurídica ambiental nacional de carácter obligatorio** de cálculo y reducción de emisiones GEI, excluyendo empresas del mercado obligatorio de carbono (art. 27 Ley 1/2005).

### 3.3 Características Singulares

#### 1) Obligación de Cálculo y Plan de Reducción

**Afecta a:**
- Empresas (art. 11.1)
- Administración General del Estado (art. 11.2)

**Requisitos:**
- Cálculo anual de huella de carbono
- Plan de reducción a **mínimo 5 años**
- Medidas concretas de consecución
- Publicación en informe de gestión

#### 2) Compensación Restringida

**Solo permitida con:**
- Créditos de carbono de **Proyectos de Absorción**
- Inscritos en **Sección b) del Registro MITECO**
- Valorados según baremo de **"alta integridad"**

Criterios de integridad:
- Indicadores medioambientales
- Indicadores socioeconómicos
- Adaptación al cambio climático

### 3.4 Diferencia con Mercado Obligatorio

| Concepto | RD 214/2025 | Mercado Obligatorio (Ley 1/2005) |
|----------|-------------|----------------------------------|
| **Sanción inicial** | No (riesgo reputacional) | Sí (multas económicas) |
| **Publicidad** | Información pública y gratuita | Registro específico UE |
| **Compensación** | Solo proyectos absorción MITECO | Derechos de emisión ETS |
| **Alcances** | 1, 2 y opcionalmente 3 | Solo emisiones directas |

---

## 4. Workflow de Análisis

### 4.1 Proceso de Determinación de Aplicabilidad

```
┌─────────────────────────────────────────────────────────────────┐
│                    FASE 1: IDENTIFICACIÓN                        │
├─────────────────────────────────────────────────────────────────┤
│ 1. ¿Es una cooperativa española?                                │
│    └─ No → RD 214/2025 no aplica (salvo otras formas jurídicas) │
│    └─ Sí → Continuar a Fase 2                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              FASE 2: VERIFICACIÓN DE UMBRALES                    │
├─────────────────────────────────────────────────────────────────┤
│ 2. ¿Cumple AL MENOS UNO de estos requisitos?                    │
│                                                                  │
│    A) Nº medio trabajadores > 500 empleados                     │
│    B) Entidad de interés público (auditoría de cuentas)         │
│    C) Durante 2 ejercicios consecutivos, al menos 2 de:         │
│        • Activo > 20M€                                           │
│        • Cifra negocios > 40M€                                   │
│        • Plantilla media > 250 empleados                         │
│                                                                  │
│    └─ No cumple ninguno → RD 214/2025 no aplica                 │
│    └─ Sí cumple alguno → Continuar a Fase 3                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│            FASE 3: APLICACIÓN DOCTRINA ICAC                      │
├─────────────────────────────────────────────────────────────────┤
│ 3. Aplicar Consulta 2 BOICAC 133/2023:                          │
│                                                                  │
│    "Las sociedades cooperativas deben incluirse en el ámbito    │
│     de aplicación de la Ley 11/2018, puesto que son sociedades  │
│     constituidas para la realización de actividades             │
│     empresariales"                                               │
│                                                                  │
│    Fundamento jurídico:                                          │
│    • Art. 1 Ley 27/1999: Cooperativas = entidades empresariales │
│    • Código de Comercio: Aplicación supletoria                  │
│    • Art. 3.1 Código Civil: Interpretación teleológica          │
│                                                                  │
│    Conclusión: Cooperativa SÍ está obligada por RD 214/2025     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              FASE 4: DETERMINACIÓN DE OBLIGACIONES               │
├─────────────────────────────────────────────────────────────────┤
│ 4. La cooperativa debe:                                          │
│                                                                  │
│    ✓ Calcular huella de carbono anualmente (alcances 1 y 2)    │
│    ✓ Elaborar plan de reducción a 5 años (con medidas)         │
│    ✓ Verificar por entidad acreditada ENAC                      │
│    ✓ Publicar en informe de gestión cuentas anuales            │
│    ✓ Inscribir en Registro MITECO                               │
│                                                                  │
│    Plazo primer cumplimiento: Cuentas 2026 (ejercicio 2025)    │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Árbol de Decisión Rápida

```python
def es_cooperativa_afectada(cooperativa):
    """
    Determina si una cooperativa está afectada por RD 214/2025
    
    Args:
        cooperativa: dict con claves {
            'forma_juridica': str,
            'num_empleados': int,
            'activo_total': float,  # en euros
            'cifra_negocios': float,  # en euros
            'plantilla_media': int,
            'entidad_interes_publico': bool,
            'ejercicios_consecutivos': int
        }
    
    Returns:
        dict: {
            'afectada': bool,
            'motivo': str,
            'obligaciones': list,
            'plazo': str
        }
    """
    
    # Fase 1: Verificar que es cooperativa
    if cooperativa['forma_juridica'].lower() != 'cooperativa':
        return {
            'afectada': False,
            'motivo': 'No es una cooperativa',
            'obligaciones': [],
            'plazo': None
        }
    
    # Fase 2: Verificar umbrales
    cumple_empleados = cooperativa['num_empleados'] > 500
    cumple_eip = cooperativa['entidad_interes_publico']
    
    # Criterios alternativos (2 de 3 durante 2 ejercicios consecutivos)
    if cooperativa['ejercicios_consecutivos'] >= 2:
        criterios = [
            cooperativa['activo_total'] > 20_000_000,
            cooperativa['cifra_negocios'] > 40_000_000,
            cooperativa['plantilla_media'] > 250
        ]
        cumple_alternativos = sum(criterios) >= 2
    else:
        cumple_alternativos = False
    
    # Evaluación final
    if not (cumple_empleados or cumple_eip or cumple_alternativos):
        return {
            'afectada': False,
            'motivo': 'No supera umbrales económicos del art. 11.1',
            'obligaciones': [],
            'plazo': None
        }
    
    # Fase 3 y 4: Aplicar doctrina ICAC y determinar obligaciones
    return {
        'afectada': True,
        'motivo': 'Supera umbrales y aplica doctrina ICAC (BOICAC 133/2023)',
        'obligaciones': [
            'Cálculo anual huella de carbono (alcances 1 y 2 obligatorios)',
            'Elaboración plan reducción a 5 años con medidas concretas',
            'Verificación por entidad acreditada ENAC',
            'Publicación en informe de gestión cuentas anuales',
            'Inscripción en Registro MITECO'
        ],
        'plazo': 'Ejercicio 2025 (reporte en cuentas 2026)',
        'doctrina_aplicable': 'ICAC Consulta 2 BOICAC 133/2023'
    }
```

---

## 5. Determinación de Aplicabilidad

### 5.1 Controversia Legal

**Problema:** El art. 11.1 del RD 214/2025 solo menciona explícitamente:
> "sociedades obligadas a formular cuentas consolidadas, de conformidad con el artículo 49.5 del Código de Comercio y el artículo 262.5 TRLSC"

**Laguna aparente:** No menciona expresamente cooperativas.

### 5.2 Solución: Doctrina ICAC

**Resolución vinculante:** Consulta 2 BOICAC 133/2023 (publicada en BOICAC 135/septiembre 2023)

#### Fundamentos de la Interpretación

**1. Naturaleza Empresarial (Art. 1 Ley 27/1999)**
```
Cooperativa = Sociedad constituida para realizar actividades empresariales
```

**2. Aplicación Supletoria del Código de Comercio**
```
Código de Comercio → Aplicable supletoriamente a cooperativas
→ Art. 49.5 incluye implícitamente a cooperativas
```

**3. Interpretación Teleológica (Art. 3.1 Código Civil)**
```
"Las normas se interpretarán atendiendo fundamentalmente 
al espíritu y finalidad de aquellas"

Propósito del RD 214/2025:
• Combatir cambio climático
• Transparencia empresarial
• Información no financiera

→ Excluir cooperativas contradiría el espíritu de la norma
```

**4. Precedente Administrativo Vinculante**
```
ICAC = Máxima autoridad contable española
→ Doctrina administrativa orienta aplicación práctica
→ Tribunales deferir a interpretación técnica ICAC
```

### 5.3 Conclusión Legal

> **Las cooperativas que superen los umbrales económicos están sujetas al RD 214/2025**, conforme a interpretación extensiva fundamentada en:
> 1. Doctrina ICAC (autoridad administrativa competente)
> 2. Naturaleza empresarial de cooperativas
> 3. Aplicación supletoria del Código de Comercio
> 4. Principio de interpretación teleológica

**Seguridad jurídica:** Alta (doctrina administrativa vinculante)  
**Precedente judicial:** Pendiente (norma reciente)  
**Riesgo de impugnación:** Bajo (fundamentación sólida)

---

## 6. Obligaciones de Cumplimiento

### 6.1 Matriz de Obligaciones

| Obligación | Descripción | Periodicidad | Verificación | Sanción |
|-----------|-------------|--------------|--------------|---------|
| **Cálculo HC** | Huella carbono alcances 1 y 2 | Anual | ENAC | Reputacional |
| **Alcance 3** | Emisiones indirectas | Opcional | ENAC | N/A |
| **Plan reducción** | Horizonte mínimo 5 años | Quinquenal | ENAC | Reputacional |
| **Medidas concretas** | Acciones específicas reducción | Incluido en plan | ENAC | Reputacional |
| **Publicación** | Informe gestión cuentas anuales | Anual | Auditoría | Legal |
| **Inscripción MITECO** | Registro oficial | Anual | Automática | Administrativa |

### 6.2 Alcances de Emisiones

#### Alcance 1: Emisiones Directas (OBLIGATORIO)

**Definición:** Emisiones GEI directas de fuentes controladas por la organización.

**Ejemplos:**
- Combustión en calderas, hornos, vehículos propios
- Procesos químicos (producción cemento, aluminio)
- Emisiones fugitivas (fugas refrigerantes, metano)
- Combustión móvil (flota de vehículos)

**Fórmula básica:**
```
Alcance 1 = Σ (Consumo_combustible_i × Factor_emisión_i)
```

#### Alcance 2: Emisiones Indirectas Energía (OBLIGATORIO)

**Definición:** Emisiones GEI indirectas por generación de electricidad/energía adquirida y consumida.

**Ejemplos:**
- Electricidad comprada a la red
- Vapor adquirido
- Calefacción/refrigeración comprada
- Aire comprimido adquirido

**Fórmula básica:**
```
Alcance 2 = Σ (Consumo_electricidad_kWh × Factor_emisión_red)
```

**Factor emisión 2025 (España):** ~0.21 kg CO₂/kWh (mix eléctrico)

#### Alcance 3: Otras Emisiones Indirectas (VOLUNTARIO)

**Definición:** Resto de emisiones indirectas en la cadena de valor.

**Art. 6.3 RD 214/2025:**
> "La inscripción de las restantes emisiones indirectas, denominadas de «alcance 3», será **voluntaria**"

**Categorías (15 según GHG Protocol):**

**Upstream (aguas arriba):**
1. Bienes y servicios adquiridos
2. Bienes de capital
3. Energía no incluida en alcances 1-2
4. Transporte y distribución upstream
5. Residuos generados
6. Viajes de negocios
7. Desplazamientos empleados (commuting)
8. Activos arrendados upstream

**Downstream (aguas abajo):**
9. Transporte y distribución downstream
10. Procesamiento de productos vendidos
11. Uso de productos vendidos
12. Fin de vida de productos vendidos
13. Activos arrendados downstream
14. Franquicias
15. Inversiones

**Recomendación:** Calcular alcance 3 solo si:
- Es materialmente significativo (>25% total)
- Mejora posicionamiento competitivo
- Exigido por clientes/inversores
- Estrategia de liderazgo climático

### 6.3 Plan de Reducción a 5 Años

#### Estructura Obligatoria

```markdown
# Plan de Reducción de Emisiones GEI 2025-2030

## 1. Línea Base
- Año base: 2025
- HC Alcance 1: XXX tCO₂e
- HC Alcance 2: YYY tCO₂e
- HC Alcance 3 (voluntario): ZZZ tCO₂e
- Total: XXX tCO₂e

## 2. Objetivos de Reducción
- Reducción 2026: -X% (vs 2025)
- Reducción 2027: -Y% (vs 2025)
- Reducción 2028: -Z% (vs 2025)
- Reducción 2029: -W% (vs 2025)
- Reducción 2030: -V% (vs 2025)

## 3. Medidas Concretas

### Medida 1: [Nombre]
- **Descripción:** [Detalle técnico]
- **Alcance afectado:** 1 / 2 / 3
- **Reducción estimada:** XXX tCO₂e/año
- **Inversión requerida:** XXX €
- **Plazo implementación:** [Fechas]
- **KPIs:** [Indicadores seguimiento]

### Medida 2: [Nombre]
...

## 4. Presupuesto Total
- Inversión total: XXX.XXX €
- Coste anual operativo: XX.XXX €/año
- Ahorro energético: XX.XXX €/año
- Payback: X.X años

## 5. Gobernanza
- Responsable: [Cargo]
- Comité seguimiento: [Miembros]
- Periodicidad revisión: [Trimestral/Semestral]

## 6. Verificación
- Entidad verificadora: [Acreditada ENAC]
- Fecha verificación: [Anual]
```

#### Ejemplos de Medidas Concretas

**Alcance 1 - Eficiencia Energética:**
- Sustitución calderas gasoil por biomasa
- Renovación flota vehículos a eléctricos/híbridos
- Instalación sistemas cogeneración

**Alcance 2 - Energías Renovables:**
- Instalación fotovoltaica autoconsumo
- Contrato electricidad renovable (GdO)
- Optimización consumos (building management system)

**Alcance 3 - Cadena de Valor:**
- Programa proveedores sostenibles
- Optimización logística (reducir km)
- Ecodiseño productos (reducir huella uso)

### 6.4 Plazos de Cumplimiento

```
Timeline RD 214/2025 para Cooperativas:

2025
│
├─ Jun: RD 214/2025 entra en vigor (12/06/2025)
│
├─ Jul-Dic: Ejercicio 2025 afectado
│        └─ Recopilar datos actividad para HC
│
2026
│
├─ Ene-Mar: Calcular HC 2025
│        └─ Elaborar plan reducción 2025-2030
│
├─ Abr-May: Verificación ENAC
│        └─ Obtener informe verificación
│
├─ Jun-Jul: Preparar cuentas anuales 2025
│        └─ Incluir información no financiera
│
├─ Ago-Sep: Aprobar cuentas anuales
│        └─ Publicar informe gestión con HC
│
└─ Oct-Dic: Inscripción Registro MITECO
         └─ Información pública disponible

2027 y sucesivos: Repetir ciclo anualmente
```

**Fecha límite crítica:** Aprobación cuentas 2025 (típicamente junio-septiembre 2026)

---

## 7. Compensación de Emisiones

### 7.1 Jerarquía de Mitigación

```
┌─────────────────────────────────────────────────────────┐
│  PRIORIDAD 1: REDUCIR                                    │
│  ─────────────────────────                               │
│  • Eficiencia energética                                 │
│  • Energías renovables                                   │
│  • Optimización procesos                                 │
│  • Cambio tecnológico                                    │
│                                                          │
│  ✓ Obligatorio: Plan de reducción a 5 años             │
└─────────────────────────────────────────────────────────┘
                       ↓
          (Solo si técnica/económicamente
           no viable reducir más)
                       ↓
┌─────────────────────────────────────────────────────────┐
│  PRIORIDAD 2: COMPENSAR                                  │
│  ─────────────────────────                               │
│  • Solo con Proyectos Absorción MITECO                  │
│  • Inscritos Sección b) Registro                        │
│  • Valorados según baremo "alta integridad"             │
│                                                          │
│  ⚠ Restricción: No cualquier crédito voluntario        │
└─────────────────────────────────────────────────────────┘
```

### 7.2 Requisitos de Compensación

#### Fuentes Permitidas (EXCLUSIVAMENTE)

**Art. 11.1 RD 214/2025:**
> "las empresas afectadas por este Real Decreto solo pueden compensar con los Proyectos de absorción de carbono, es decir, con Proyectos de ejecución de **bosques nuevos** que se deberán inscribir en la **Sección b) del Registro del MITECO**"

**Definición:** Proyectos de absorción = Reforestación/forestación nueva

❌ **NO permitidos para compensación:**
- Créditos VCS (Verified Carbon Standard)
- Créditos Gold Standard
- Créditos ACR (American Carbon Registry)
- Créditos internacionales Art. 6 Acuerdo París
- Proyectos conservación (evitación deforestación)
- Proyectos energías renovables
- Proyectos captura industrial

✅ **SÍ permitidos:**
- Proyectos forestación/reforestación España
- Inscritos Sección b) Registro MITECO
- Con certificación "alta integridad"

#### Criterios de Alta Integridad

**Baremo MITECO incluye:**

1. **Indicadores Medioambientales**
   - Biodiversidad (especies autóctonas vs alóctonas)
   - Servicios ecosistémicos (regulación hídrica, suelo)
   - Resiliencia climática (adaptación sequías, incendios)
   - Permanencia secuestro (>40 años)

2. **Indicadores Socioeconómicos**
   - Generación empleo local
   - Desarrollo rural
   - Implicación comunidades locales
   - Gobernanza participativa

3. **Indicadores Adaptación Cambio Climático**
   - Especies resistentes estrés hídrico
   - Diversidad genética
   - Diseño mosaico paisajístico
   - Gestión riesgo incendios

**Sistema de puntuación (orientativo):**
```
Puntuación total = 0.4 × Medioambiental + 0.3 × Socioeconómico + 0.3 × Adaptación

Alta integridad: Puntuación ≥ 75/100
```

### 7.3 Proceso de Compensación

```
┌──────────────────────────────────────────────────────────────┐
│ PASO 1: Calcular Emisiones Residuales                        │
├──────────────────────────────────────────────────────────────┤
│ Emisiones residuales = Emisiones año N - Reducción alcanzada│
│                                                               │
│ Ejemplo:                                                      │
│ • HC 2025 (línea base): 10.000 tCO₂e                        │
│ • Objetivo reducción 2030: -40%                              │
│ • Reducción alcanzada: -35% = 3.500 tCO₂e                   │
│ • Emisiones 2030: 6.500 tCO₂e                               │
│ • Gap vs objetivo: 500 tCO₂e                                 │
│   → Emisiones residuales a compensar: 500 tCO₂e            │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PASO 2: Buscar Proyectos Elegibles MITECO                    │
├──────────────────────────────────────────────────────────────┤
│ Consultar: Registro MITECO > Sección b) Proyectos Absorción │
│                                                               │
│ Filtrar por:                                                  │
│ • Estado: Activo                                             │
│ • Créditos disponibles: > Cantidad necesaria                │
│ • Puntuación integridad: ≥ 75/100                           │
│ • Ubicación: Preferiblemente misma CA                        │
│ • Precio: Dentro de presupuesto                              │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PASO 3: Adquirir Créditos CCF                                │
├──────────────────────────────────────────────────────────────┤
│ • Negociar con titular proyecto                              │
│ • Precio referencia 2025: 15-40 €/tCO₂ (proyectos MITECO)  │
│ • Formalizar contrato compraventa                            │
│ • Transferir créditos en Registro MITECO                     │
│                                                               │
│ Coste ejemplo:                                                │
│ 500 tCO₂e × 25 €/tCO₂ = 12.500 €                           │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PASO 4: Declarar Compensación                                │
├──────────────────────────────────────────────────────────────┤
│ • Incluir en informe gestión cuentas anuales:                │
│   - Emisiones residuales compensadas                         │
│   - Proyecto(s) utilizados (ID Registro MITECO)             │
│   - Cantidad créditos cancelados                             │
│   - Justificación no viabilidad reducción adicional         │
│                                                               │
│ • Verificar por entidad ENAC                                 │
│ • Cancelar créditos en Registro MITECO                       │
└──────────────────────────────────────────────────────────────┘
```

### 7.4 Diferencia CCV vs CCF

| Concepto | CCV (Crédito Carbono Voluntario) | CCF (Crédito Carbono Forestal) |
|----------|-----------------------------------|----------------------------------|
| **Origen** | Proyectos voluntarios internacionales | Proyectos forestales España |
| **Estándares** | VCS, Gold Standard, ACR, etc. | Metodología MITECO/IPCC |
| **Registro** | Registros privados | Registro MITECO oficial |
| **Elegible RD 214/2025** | ❌ NO | ✅ SÍ (Sección b) |
| **Precio 2025** | 5-20 €/tCO₂ | 15-40 €/tCO₂ |
| **Permanencia** | Variable (10-100 años) | Mínimo 40 años |
| **Adicionalidad** | Variable | Verificada MITECO |

**Implicación práctica:** Cooperativas afectadas por RD 214/2025 **no pueden compensar con CCV** adquiridos en mercados voluntarios internacionales. Solo sirven **CCF de proyectos MITECO**.

---

## 8. Casos de Uso y Ejemplos

### 8.1 Caso 1: Cooperativa Agrícola Grande

**Perfil:**
- Forma jurídica: Cooperativa agraria
- Ubicación: Andalucía
- Actividad: Producción y comercialización aceite oliva
- Empleados: 320
- Activo: 28M€
- Cifra negocios: 55M€
- Plantilla media: 280

**Análisis:**

```python
cooperativa_olivar = {
    'forma_juridica': 'cooperativa',
    'num_empleados': 320,
    'activo_total': 28_000_000,
    'cifra_negocios': 55_000_000,
    'plantilla_media': 280,
    'entidad_interes_publico': False,
    'ejercicios_consecutivos': 2
}

resultado = es_cooperativa_afectada(cooperativa_olivar)
```

**Output:**
```json
{
  "afectada": true,
  "motivo": "Supera umbrales (activo>20M€, negocio>40M€, plantilla>250) y aplica doctrina ICAC",
  "obligaciones": [
    "Cálculo anual huella de carbono (alcances 1 y 2)",
    "Plan reducción 5 años con medidas",
    "Verificación ENAC",
    "Publicación informe gestión",
    "Inscripción MITECO"
  ],
  "plazo": "Ejercicio 2025 (reporte cuentas 2026)"
}
```

**Fuentes principales de emisiones:**
- **Alcance 1:** Maquinaria agrícola (tractores, cosechadoras), calderas almazara, transporte productos
- **Alcance 2:** Electricidad almazara (extracción, embotellado, refrigeración)
- **Alcance 3 (voluntario):** Fertilizantes, fitosanitarios, transporte empleados, distribución producto

**Plan de reducción sugerido:**
1. **Medida 1:** Fotovoltaica autoconsumo 500 kWp → -350 tCO₂e/año (Alcance 2)
2. **Medida 2:** Renovación flota tractores a biodiesel → -80 tCO₂e/año (Alcance 1)
3. **Medida 3:** Optimización proceso térmico almazara → -120 tCO₂e/año (Alcance 1)

**Compensación residual:** Si tras medidas quedan emisiones, buscar proyectos reforestación olivar en misma comarca (alta integridad, cobeneficio paisaje).

### 8.2 Caso 2: Cooperativa Industrial Mediana

**Perfil:**
- Forma jurídica: Cooperativa de trabajo asociado
- Ubicación: País Vasco
- Actividad: Fabricación componentes metal
- Empleados: 180
- Activo: 15M€
- Cifra negocios: 25M€
- Plantilla media: 180

**Análisis:**

```python
cooperativa_metal = {
    'forma_juridica': 'cooperativa',
    'num_empleados': 180,
    'activo_total': 15_000_000,
    'cifra_negocios': 25_000_000,
    'plantilla_media': 180,
    'entidad_interes_publico': False,
    'ejercicios_consecutivos': 2
}

resultado = es_cooperativa_afectada(cooperativa_metal)
```

**Output:**
```json
{
  "afectada": false,
  "motivo": "No supera umbrales económicos del art. 11.1 (activo<20M€, negocio<40M€, plantilla<250)",
  "obligaciones": [],
  "plazo": null
}
```

**Conclusión:** Esta cooperativa **NO está obligada** por RD 214/2025. Sin embargo, puede inscribirse voluntariamente en Registro MITECO para:
- Ventaja competitiva (licitaciones públicas)
- Exigencias clientes (cadena suministro)
- Acceso financiación verde
- Reputación corporativa

### 8.3 Caso 3: Cooperativa Servicios Grande (EIP)

**Perfil:**
- Forma jurídica: Cooperativa de crédito
- Ubicación: Madrid
- Actividad: Servicios financieros
- Empleados: 1.200
- Activo: 800M€
- Cifra negocios: 45M€
- Plantilla media: 1.100
- Entidad Interés Público: SÍ (entidad financiera)

**Análisis:**

```python
cooperativa_credito = {
    'forma_juridica': 'cooperativa',
    'num_empleados': 1200,
    'activo_total': 800_000_000,
    'cifra_negocios': 45_000_000,
    'plantilla_media': 1100,
    'entidad_interes_publico': True,  # ← Factor determinante
    'ejercicios_consecutivos': 5
}

resultado = es_cooperativa_afectada(cooperativa_credito)
```

**Output:**
```json
{
  "afectada": true,
  "motivo": "Es Entidad de Interés Público + supera todos los umbrales. Aplica doctrina ICAC.",
  "obligaciones": [
    "Cálculo anual huella de carbono (alcances 1 y 2)",
    "Plan reducción 5 años con medidas",
    "Verificación ENAC",
    "Publicación informe gestión",
    "Inscripción MITECO"
  ],
  "plazo": "Ejercicio 2025 (reporte cuentas 2026)"
}
```

**Particularidades sector financiero:**

**Huella de carbono típica:**
- **Alcance 1:** Mínimo (sin procesos industriales). Flotas vehículos empresa si existen.
- **Alcance 2:** Alto (oficinas, datacenter, climatización, iluminación)
- **Alcance 3:** Muy alto si incluye cartera inversión/crédito (financed emissions)

**Debate alcance 3 financiero:**
- Emisiones financiadas (financed emissions) entran en alcance 3
- Metodología: PCAF (Partnership for Carbon Accounting Financials)
- Altamente complejo y no obligatorio inicialmente
- Presión regulatoria futura: Taxonomía UE, CSRD

**Plan de reducción sugerido:**
1. **Medida 1:** Eficiencia energética oficinas (LED, climatización) → -400 tCO₂e/año
2. **Medida 2:** Contrato electricidad 100% renovable (GdO) → -2.000 tCO₂e/año
3. **Medida 3:** Política inversión/crédito sostenible → -% indirecto (alcance 3)

### 8.4 Caso 4: Cooperativa Forestal (Proyecto Absorción)

**Perfil:**
- Forma jurídica: Cooperativa forestal
- Ubicación: Galicia
- Actividad: Gestión forestal y reforestación
- Empleados: 45
- Hectáreas gestionadas: 5.000 ha
- Activo: 8M€
- Cifra negocios: 3M€

**Análisis RD 214/2025:**

```json
{
  "afectada": false,
  "motivo": "No supera umbrales económicos",
  "obligaciones": []
}
```

**Oportunidad complementaria:**

Aunque NO obligada a calcular su propia huella, esta cooperativa puede:

1. **Desarrollar proyectos de absorción** para terceros
2. **Inscribir en Sección b) Registro MITECO**
3. **Generar créditos CCF** para empresas obligadas por RD 214/2025
4. **Monetizar servicios ecosistémicos**

**Ejemplo proyecto:**

```
Proyecto: Reforestación 750 ha especies autóctonas
─────────────────────────────────────────────────
• Ubicación: Montes vecinales Galicia
• Especies: Roble, castaño, abedul (biodiversidad alta)
• Secuestro estimado: 150.000 tCO₂ (40 años)
• Generación créditos: 3.750 CCF/año × 40 años
• Precio estimado: 25 €/CCF
• Ingresos potenciales: 93.750 €/año
• Puntuación integridad: 85/100 (alta)

Cobeneficos:
✓ Empleo rural (15 empleos directos)
✓ Biodiversidad (hábitat fauna autóctona)
✓ Regulación hídrica (recarga acuíferos)
✓ Prevención incendios (mosaico paisajístico)
✓ Adaptación climática (especies resilientes)
```

**Mercado objetivo:** Cooperativas grandes obligadas por RD 214/2025 que necesiten compensar emisiones residuales.

---

## 9. Referencias Técnicas

### 9.1 Normativa Aplicable

#### Normativa Principal

- **Real Decreto 214/2025, de 18 de marzo** - Registro huella de carbono y obligaciones de cálculo y reducción
  - Entrada en vigor: 12 de junio de 2025
  - Deroga: RD 163/2014

- **Ley 11/2018, de 28 de diciembre** - Información no financiera y diversidad
  - Modifica: Código de Comercio (art. 49.5)
  - Transpone: Directiva 2014/95/UE

- **Ley 27/1999, de 16 de julio** - Cooperativas
  - Define naturaleza empresarial cooperativas

- **Código de Comercio** - Arts. 49.5 (información no financiera)
  - Aplicación supletoria a cooperativas

- **Texto Refundido Ley Sociedades Capital (TRLSC)** - Art. 262.5
  - Umbrales cuentas consolidadas

#### Doctrina Administrativa

- **ICAC Consulta 2 BOICAC 133/2023** (publicada BOICAC 135/septiembre 2023)
  - Establece aplicabilidad a cooperativas
  - Doctrina administrativa vinculante

#### Normativa Complementaria

- **Ley 1/2005, de 9 de marzo** - Régimen comercio derechos emisión GEI
  - Define mercado obligatorio carbono
  - Art. 27: Obligaciones empresas afectadas

- **Ley 7/2021, de 20 de mayo** - Cambio climático y transición energética
  - Marco general descarbonización España

### 9.2 Metodologías y Estándares

#### Cálculo Huella de Carbono

- **GHG Protocol Corporate Standard** (WBCSD/WRI)
  - Estándar internacional de referencia
  - Define alcances 1, 2 y 3

- **ISO 14064-1:2018** - Cuantificación e informe de emisiones y remociones GEI
  - Norma técnica verificación

- **Guía MITECO** - Cálculo huella de carbono organizaciones (España)
  - Adaptación metodología a legislación española
  - Factores emisión actualizados

#### Proyectos de Absorción

- **Real Decreto 214/2025** - Anexo sobre proyectos absorción
  - Metodología cálculo secuestro
  - Requisitos inscripción Registro

- **Guía IPCC AFOLU** (Agriculture, Forestry and Other Land Use)
  - Metodología internacional sector forestal

### 9.3 Factores de Emisión España (2025)

#### Alcance 1 - Combustión Estacionaria

| Combustible | Factor Emisión | Unidad | Fuente |
|-------------|----------------|--------|--------|
| Gas natural | 2.01 kg CO₂/Nm³ | 0.202 kg CO₂/kWh PCI | MITECO 2025 |
| Gasóleo C | 2.96 kg CO₂/litro | 3.18 kg CO₂/kg | MITECO 2025 |
| GLP (propano) | 1.67 kg CO₂/litro | 2.94 kg CO₂/kg | MITECO 2025 |
| Biomasa forestal | 0.00 kg CO₂/kg* | - | Neutro (ciclo corto) |

*Neutro en CO₂ biogénico, pero considerar CH₄ y N₂O en combustión.

#### Alcance 1 - Combustión Móvil

| Combustible | Factor Emisión | Fuente |
|-------------|----------------|--------|
| Gasolina | 2.30 kg CO₂/litro | MITECO 2025 |
| Gasóleo A | 2.52 kg CO₂/litro | MITECO 2025 |
| Biodiesel | 0.00 kg CO₂/litro* | Neutro (ciclo corto) |

#### Alcance 2 - Electricidad

| Fuente | Factor Emisión 2025 | Comentario |
|--------|---------------------|-----------|
| Mix red España | 0.210 kg CO₂/kWh | Promedio peninsular |
| Renovable (GdO) | 0.000 kg CO₂/kWh | Con Garantías Origen |
| Baleares | 0.650 kg CO₂/kWh | Sistema aislado |
| Canarias | 0.720 kg CO₂/kWh | Sistema aislado |

**Nota:** Factores actualizados anualmente por MITECO en base a:
- Mix generación real
- Interconexiones internacionales
- Penetración renovables

### 9.4 Precio Referencia Créditos Carbono

#### CCF - Créditos Carbono Forestal (Proyectos MITECO)

**Rango precio 2025:** 15-40 €/tCO₂

**Factores que influyen:**
- Puntuación integridad (>80/100 → precio premium)
- Ubicación (proximidad geográfica)
- Cobenefcios (biodiversidad, empleo rural)
- Permanencia (>50 años → precio superior)
- Volumen transacción (descuentos por cantidad)

**Precio medio observado:** ~25 €/tCO₂ (proyectos calidad media-alta)

#### CCV - Créditos Carbono Voluntario (NO elegibles RD 214/2025)

Para referencia comparativa:

| Estándar | Precio 2025 | Comentario |
|----------|-------------|-----------|
| VCS - Forestal | 8-15 €/tCO₂ | Mercado voluntario internacional |
| Gold Standard | 12-20 €/tCO₂ | Mayor rigor metodológico |
| ACR - Agricultura | 10-18 €/tCO₂ | Norteamérica principalmente |

**Tendencia:** Precios CCV aumentando por presión demanda corporativa neta-cero, pero siguen por debajo de CCF MITECO debido a mayor rigor regulatorio español.

### 9.5 Entidades Verificadoras ENAC

**Requisito:** Verificación por entidad acreditada ENAC (Entidad Nacional Acreditación).

**Listado actualizado:**
Consultar: https://www.enac.es/web/enac/entidades-acreditadas

**Búsqueda:** Acreditación "Verificación huella de carbono ISO 14064"

**Principales verificadoras España (2025):**
- AENOR
- Bureau Veritas
- SGS
- TÜV Rheinland
- LGAI Applus+
- ECA (Entidad Colaboradora Administración)

**Coste orientativo verificación:**
- Pequeña cooperativa (<500 tCO₂e): 2.000-4.000 €
- Mediana cooperativa (500-5.000 tCO₂e): 4.000-8.000 €
- Gran cooperativa (>5.000 tCO₂e): 8.000-15.000 €

**Incluye:**
- Revisión metodología cálculo
- Auditoría documental
- Verificación in situ (si aplica)
- Informe verificación
- Declaración conformidad

### 9.6 Registro MITECO

**Acceso:** https://www.miteco.gob.es/es/cambio-climatico/temas/mitigacion-politicas-y-medidas/registro-huella-carbono.html

**Estructura:**

```
Registro MITECO
│
├── Sección a) Huella de Carbono
│   ├── Subsección a.1) Cálculo
│   ├── Subsección a.2) Cálculo + Reducción
│   └── Subsección a.3) Cálculo + Reducción + Compensación
│
└── Sección b) Proyectos de Absorción
    ├── Proyectos forestación
    ├── Proyectos reforestación
    └── Proyectos gestión forestal mejorada
```

**Para cooperativas obligadas RD 214/2025:**
- Inscripción en Sección a) obligatoria
- Subsección a.2) mínimo (cálculo + reducción)
- Subsección a.3) si compensan

**Información pública:**
- Razón social y CIF
- Huella de carbono anual
- Plan de reducción (objetivos)
- Proyectos compensación utilizados
- Histórico años anteriores

**Privacidad:** Medidas concretas del plan pueden ser confidenciales (know-how).

### 9.7 Glosario Técnico

**Adicionalidad:** Principio que exige que un proyecto de reducción/absorción genere beneficio climático adicional que no ocurriría en ausencia del proyecto.

**Alcance 1, 2, 3:** Categorías de emisiones GEI según control operacional y punto de la cadena de valor donde ocurren.

**CCF:** Crédito de Carbono Forestal. Unidad equivalente a 1 tCO₂ secuestrada por proyectos forestales inscritos en Registro MITECO.

**CCV:** Crédito de Carbono Voluntario. Unidad de mercados voluntarios internacionales (VCS, Gold Standard, etc.).

**ENAC:** Entidad Nacional de Acreditación. Organismo que acredita verificadores de huella de carbono en España.

**Forestación:** Establecimiento de bosque en terreno que históricamente no era forestal (>50 años sin cubierta arbórea).

**GEI:** Gases de Efecto Invernadero. Principales: CO₂, CH₄, N₂O, HFC, PFC, SF₆.

**GdO:** Garantía de Origen. Certificado que acredita origen renovable de electricidad.

**ICAC:** Instituto de Contabilidad y Auditoría de Cuentas. Autoridad contable española.

**Línea base:** Año de referencia para medir reducciones de emisiones (típicamente primer año de cálculo).

**MITECO:** Ministerio para la Transición Ecológica y el Reto Demográfico.

**PCI:** Poder Calorífico Inferior. Energía liberada por combustión sin considerar calor latente de vaporización del agua.

**Reforestación:** Re-establecimiento de bosque en terreno que fue forestal pero perdió cubierta arbórea (<50 años).

**tCO₂e:** Tonelada de CO₂ equivalente. Unidad que agrega todos los GEI usando potenciales de calentamiento global (GWP).

**TRLSC:** Texto Refundido de la Ley de Sociedades de Capital.

---

## 10. Instrucciones de Ejecución para Claude

### 10.1 Protocolo de Activación

**Cuando recibas una consulta sobre cooperativas y carbono:**

1. **Identificar trigger:** ¿Menciona RD 214/2025, huella carbono obligatoria, cooperativas afectadas?

2. **Recopilar datos esenciales:**
   ```
   CHECKLIST:
   □ Forma jurídica (confirmar que es cooperativa)
   □ Nº empleados
   □ Activo total (últimos 2 ejercicios)
   □ Cifra negocios (últimos 2 ejercicios)
   □ Plantilla media (últimos 2 ejercicios)
   □ ¿Entidad Interés Público? (financieras, cotizadas, etc.)
   ```

3. **Ejecutar workflow Fase 1-4** del apartado 4.1

4. **Determinar respuesta:**
   - Si afectada → Detallar obligaciones + plazos
   - Si no afectada → Explicar por qué + mencionar voluntariedad
   - Si dudoso → Solicitar datos adicionales

### 10.2 Formato de Respuesta Estándar

```markdown
## Análisis de Aplicabilidad RD 214/2025

### Datos de la Cooperativa
- Forma jurídica: [X]
- Empleados: [X]
- Activo: [X] M€
- Cifra negocios: [X] M€
- Plantilla media: [X]

### Evaluación de Umbrales
[Tabla comparativa con requisitos]

### Conclusión
✅/❌ [Afectada/No afectada]

**Fundamento jurídico:** [Explicar aplicando doctrina ICAC si procede]

### Obligaciones (si afectada)
1. [Lista numerada]

### Plazos Clave
- [Timeline]

### Recomendaciones
- [Acciones concretas]
```

### 10.3 Casos Especiales

**Si usuario pregunta por "sociedad anónima" o "SL":**
- Aplicación directa art. 11.1 sin necesidad doctrina ICAC
- Más sencillo (no hay controversia)

**Si usuario pregunta por "asociación" o "fundación":**
- NO aplicable RD 214/2025 (no son sociedades mercantiles)
- Pueden inscribirse voluntariamente
- Explicar diferencia con cooperativas

**Si usuario pregunta por compensación con créditos internacionales:**
- Explicar claramente: ❌ NO elegibles para cumplir RD 214/2025
- Solo CCF MITECO Sección b)
- Diferenciar CCV vs CCF (apartado 7.4)

**Si usuario solicita calcular huella de carbono:**
- Esta skill NO calcula directamente
- Remitir a skill `forest-carbon-calculator` si es proyecto forestal
- Proporcionar metodología y factores emisión (apartado 9.3)
- Recomendar contratar verificador ENAC

### 10.4 Nivel de Detalle

**Adaptarlo según pregunta del usuario:**

- **Pregunta simple** ("¿Mi cooperativa está afectada?")
  → Respuesta ejecutiva: SÍ/NO + 1 párrafo fundamento

- **Pregunta técnica** ("¿Cómo se calcula alcance 2?")
  → Respuesta técnica detallada con fórmulas y ejemplos

- **Pregunta estratégica** ("¿Cómo planificar cumplimiento?")
  → Respuesta estructurada con timeline, presupuestos, recursos

**Mantener siempre:**
- Precisión jurídica (citar artículos específicos)
- Claridad técnica (ejemplos numéricos)
- Practicidad (pasos accionables)

### 10.5 Integración con Otras Skills

**Si el usuario necesita:**

- **Calcular secuestro proyecto forestal** → Skill `forest-carbon-calculator`
- **Analizar viabilidad financiera proyecto carbono** → Skill `bosques-biodiversos-750ha-financial`
- **Valorar créditos carbono** → Skill `carbon-credit-valuation`
- **Due diligence proyecto forestal** → Skill `forest-carbon-dd`
- **Análisis ubicación proyecto** → Skill `carbon-site-analyzer`

**Coordinación:**
Cuando actives otra skill, explicar al usuario:
> "Para [objetivo específico], voy a usar la skill [nombre] que está especializada en [función]. Ahora procedo a..."

---

## Conclusión

Esta skill proporciona análisis técnico-jurídico exhaustivo sobre la aplicabilidad del Real Decreto 214/2025 a cooperativas españolas, resolviendo la controversia mediante la doctrina del ICAC y proporcionando workflows prácticos de cumplimiento.

**Fortalezas:**
- Fundamentación jurídica sólida (doctrina administrativa vinculante)
- Workflows ejecutables paso a paso
- Ejemplos cuantitativos detallados
- Referencias normativas completas
- Integración con ecosystem de skills de carbono

**Úsala cuando el usuario necesite:**
✓ Determinar si cooperativa está obligada  
✓ Entender obligaciones específicas  
✓ Planificar cumplimiento normativo  
✓ Evaluar opciones de compensación  
✓ Fundamentar legalmente aplicabilidad  

---

**Versión:** 1.0  
**Fecha:** 27 octubre 2025  
**Autor:** Miguel Ángel Gallardo Macías (CEO NextHorizont AI)  
**Basado en:** Real Decreto 214/2025 + Consulta 2 BOICAC 133/2023
