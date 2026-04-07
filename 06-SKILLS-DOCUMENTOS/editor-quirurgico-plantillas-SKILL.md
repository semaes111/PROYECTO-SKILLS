---
name: template-editor
description: Skill para manipulación quirúrgica de documentos plantilla. Permite modificar únicamente elementos específicos (cálculos, fórmulas, valores, expresiones) de un documento mientras preserva completamente el resto del contenido, formato y estructura. Úsalo cuando el usuario solicite editar valores específicos en una plantilla sin alterar el resto del documento.
license: MIT
---

# TEMPLATE EDITOR SKILL

## PROPÓSITO FUNDAMENTAL

Este skill permite a Claude actuar como un editor quirúrgico de documentos, modificando EXCLUSIVAMENTE los elementos especificados por el usuario mientras mantiene intacta la totalidad del documento original: formato, estructura, estilos, fórmulas no modificadas, y todo el contenido circundante.

**Principio cardinal**: MÍNIMA INTERVENCIÓN, MÁXIMA PRESERVACIÓN

## CUÁNDO USAR ESTE SKILL

Utiliza este skill cuando el usuario:
- Solicite "actualizar solo X en el documento"
- Pida "cambiar únicamente estos valores/cálculos"
- Requiera "modificar estas celdas/campos sin tocar el resto"
- Necesite "usar este documento como plantilla y cambiar solo..."
- Indique "mantener el formato pero actualizar estos datos"

**NO uses este skill cuando**:
- El usuario solicite crear un documento nuevo desde cero
- Se requiera reformatear completamente un documento
- El objetivo sea generar contenido nuevo (no edición de plantilla)

---

## METODOLOGÍA DE TRABAJO: PROCESO DE 4 FASES

### FASE 1: ANÁLISIS Y MAPEO COMPLETO

**Objetivo**: Comprender exhaustivamente el documento original antes de cualquier modificación.

#### Paso 1.1: Lectura completa del documento
```bash
# Para documentos de texto/código
view /path/to/documento

# Para documentos Office
# Leer con python-docx, openpyxl, python-pptx según corresponda
```

#### Paso 1.2: Identificación de la arquitectura del documento
Determina y documenta:
- **Tipo de documento**: .docx, .xlsx, .pptx, .md, .txt, .json, .csv, .xml, etc.
- **Estructura general**: Secciones, tablas, celdas, párrafos, campos
- **Elementos de formato**: Estilos, fuentes, colores, bordes, alineaciones
- **Dependencias**: Fórmulas, referencias, vínculos internos
- **Metadata**: Propiedades del documento que deben preservarse

#### Paso 1.3: Localización precisa de elementos modificables
Identifica con exactitud:
- **Ubicación exacta**: Línea/celda/párrafo/campo específico
- **Contenido actual**: Valor/texto/fórmula existente
- **Contexto**: Elementos inmediatamente anteriores y posteriores
- **Formato aplicado**: Estilos, formato numérico, formato condicional

#### Paso 1.4: Mapeo de elementos a modificar vs elementos a preservar
Crea un mapa mental/explícito:

```
ELEMENTOS A MODIFICAR:
- Celda B5: Valor actual "1000" → Nuevo valor "1500"
- Celda C10: Fórmula "=B5*0.21" → Mantener (se actualiza automáticamente)
- Párrafo 3, línea 45: "año 2024" → "año 2025"

ELEMENTOS A PRESERVAR COMPLETAMENTE:
- Todo el resto del documento
- Formato de celdas B5, C10
- Estilos de párrafos
- Encabezados y pies de página
- Todas las demás fórmulas
- Estructura de tablas
- Imágenes y gráficos
```

### FASE 2: PLANIFICACIÓN DE EDICIÓN QUIRÚRGICA

**Objetivo**: Diseñar la estrategia de modificación con precisión milimétrica.

#### Paso 2.1: Selección del método de edición apropiado

**Para archivos de texto plano (.md, .txt, .json, .csv, .xml)**:
```
Método: str_replace (herramienta de reemplazo de cadenas)
Ventajas: Preservación perfecta del contenido no modificado
Precauciones: La cadena a buscar debe ser ÚNICA en el documento
```

**Para archivos Word (.docx)**:
```python
Método: python-docx con edición quirúrgica de elementos específicos
Pasos:
1. Cargar documento con Document()
2. Navegar a elementos específicos (párrafos, tablas, celdas)
3. Modificar SOLO el contenido del elemento target
4. Preservar todos los estilos y formato existentes
5. Guardar sin alterar estructura
```

**Para archivos Excel (.xlsx)**:
```python
Método: openpyxl con preservación de formato
Pasos:
1. Cargar workbook con load_workbook()
2. Acceder a la hoja específica
3. Modificar SOLO las celdas indicadas
4. Preservar: fórmulas, formato, formato condicional, validaciones
5. Guardar con save()
```

**Para archivos PowerPoint (.pptx)**:
```python
Método: python-pptx con edición de shapes específicos
Pasos:
1. Cargar presentación con Presentation()
2. Navegar a slide y shape específicos
3. Modificar solo el texto/valor del elemento target
4. Mantener posición, tamaño, formato
5. Guardar preservando todo lo demás
```

#### Paso 2.2: Validación de unicidad de elementos
**CRÍTICO PARA ARCHIVOS DE TEXTO**:
```python
# Antes de usar str_replace, verifica que la cadena aparece UNA SOLA VEZ
with open('documento.txt', 'r') as f:
    contenido = f.read()
    ocurrencias = contenido.count('cadena_a_buscar')
    if ocurrencias != 1:
        # USAR MÉTODO ALTERNATIVO
        # Buscar contexto más amplio o usar edición por línea/párrafo
```

#### Paso 2.3: Preparación de valores de reemplazo
- Mantener el **mismo formato** que el original
- Preservar **tipo de dato** (numérico, texto, fecha, fórmula)
- Respetar **precisión decimal** si es numérico
- Conservar **formato de fecha/hora** si aplica

### FASE 3: EJECUCIÓN QUIRÚRGICA

**Objetivo**: Realizar las modificaciones con la menor perturbación posible al documento.

#### Paso 3.1: Implementación según tipo de archivo

##### PARA ARCHIVOS DE TEXTO PLANO:

**Opción A: Usando str_replace (preferido cuando la cadena es única)**
```bash
str_replace(
    path="documento.txt",
    old_str="valor_actual_completo_con_contexto",
    new_str="valor_nuevo_completo_con_contexto",
    description="Actualizar valor X en línea Y"
)
```

**REGLA DE ORO**: Incluye suficiente contexto en `old_str` para garantizar unicidad, pero no más del necesario.

**Ejemplo correcto**:
```python
# Documento original:
# "El presupuesto para 2024 es de 50000 euros"
# Queremos cambiar solo el año

# ❌ MAL - Demasiado amplio:
old_str = "El presupuesto para 2024 es de 50000 euros"

# ❌ MAL - No único (puede haber otros "2024"):
old_str = "2024"

# ✅ BIEN - Contexto suficiente y único:
old_str = "presupuesto para 2024 es"
new_str = "presupuesto para 2025 es"
```

**Opción B: Lectura, modificación y recreación (cuando hay múltiples modificaciones)**
```python
# Lee el archivo
with open('documento.txt', 'r', encoding='utf-8') as f:
    lineas = f.readlines()

# Modifica SOLO las líneas específicas
lineas[44] = lineas[44].replace('2024', '2025')  # Línea 45 (índice 44)
lineas[67] = '    valor_nuevo: 1500\n'  # Línea 68, mantén la indentación

# Reescribe el archivo
with open('documento.txt', 'w', encoding='utf-8') as f:
    f.writelines(lineas)
```

##### PARA ARCHIVOS WORD (.docx):

```python
from docx import Document

# Carga el documento
doc = Document('/path/to/plantilla.docx')

# ESCENARIO 1: Modificar texto en párrafo específico
# Encuentra el párrafo exacto (por índice o contenido)
for para in doc.paragraphs:
    if 'texto_identificador' in para.text:
        # Preserva el formato del run existente
        for run in para.runs:
            if 'valor_a_cambiar' in run.text:
                run.text = run.text.replace('valor_a_cambiar', 'valor_nuevo')
        break

# ESCENARIO 2: Modificar celda en tabla
tabla = doc.tables[0]  # Primera tabla
celda = tabla.rows[2].cells[3]  # Fila 3, Columna 4
# Preserva formato del párrafo existente
celda.paragraphs[0].text = 'nuevo_valor'

# ESCENARIO 3: Modificar campo numérico manteniendo formato
para = doc.paragraphs[5]
# Si el párrafo tiene formato específico, mantén los runs
if len(para.runs) > 0:
    # Modifica solo el run que contiene el valor
    para.runs[0].text = '1500'  # Mantiene formato del run

# Guarda en outputs
doc.save('/mnt/user-data/outputs/documento_actualizado.docx')
```

**ADVERTENCIAS CRÍTICAS PARA WORD**:
- ❌ NO recrees párrafos desde cero (pierdes formato)
- ❌ NO uses `para.clear()` a menos que sea absolutamente necesario
- ✅ MODIFICA el contenido de runs existentes cuando sea posible
- ✅ PRESERVA la estructura de runs (bold, italic, color se almacenan ahí)

##### PARA ARCHIVOS EXCEL (.xlsx):

```python
from openpyxl import load_workbook
from openpyxl.styles import numbers

# Carga el workbook COMPLETO (preserva todo)
wb = load_workbook('/path/to/plantilla.xlsx')
ws = wb['NombreHoja']  # o wb.active

# ESCENARIO 1: Modificar valor simple
ws['B5'] = 1500  # Celda B5
# El formato de la celda se preserva automáticamente

# ESCENARIO 2: Modificar manteniendo formato numérico explícito
celda = ws['C10']
celda.value = 1250.50
# Si necesitas formato específico:
# celda.number_format = '#,##0.00'  # Solo si cambias formato

# ESCENARIO 3: Modificar fórmula (raro, normalmente se preservan)
ws['D15'] = '=SUM(D5:D14)'  # Solo si necesitas cambiar la fórmula

# ESCENARIO 4: Modificar múltiples celdas
cambios = {
    'B5': 1500,
    'B6': 2300,
    'C5': 'Nuevo texto'
}
for celda_ref, valor in cambios.items():
    ws[celda_ref] = valor

# Guarda en outputs
wb.save('/mnt/user-data/outputs/documento_actualizado.xlsx')
```

**ADVERTENCIAS CRÍTICAS PARA EXCEL**:
- ✅ `load_workbook()` preserva automáticamente: formato, fórmulas, validaciones, formato condicional
- ❌ NO modifiques celdas que contienen fórmulas a menos que sea explícitamente solicitado
- ✅ Las fórmulas que referencian celdas modificadas se recalculan automáticamente al abrir
- ❌ NO uses `data_only=True` en load_workbook (pierdes las fórmulas)

##### PARA ARCHIVOS JSON/YAML:

```python
import json

# Lee el archivo
with open('/path/to/config.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Modifica SOLO el valor específico
data['configuracion']['presupuesto']['cantidad'] = 1500
data['configuracion']['año'] = 2025

# Guarda preservando formato (indent)
with open('/mnt/user-data/outputs/config_actualizado.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

#### Paso 3.2: Verificación inmediata post-modificación
Después de cada modificación:
```python
# Para archivos de texto
view /mnt/user-data/outputs/documento_actualizado.txt

# Para archivos binarios (Word, Excel)
# Informa al usuario que el archivo está listo y explica brevemente qué se modificó
```

### FASE 4: VALIDACIÓN Y ENTREGA

**Objetivo**: Confirmar que la modificación fue exitosa y el documento es funcional.

#### Paso 4.1: Checklist de validación

**Para TODOS los tipos de archivo**:
- [ ] Las modificaciones solicitadas se aplicaron correctamente
- [ ] NO se modificó ningún elemento no solicitado
- [ ] El documento se guarda correctamente en `/mnt/user-data/outputs/`
- [ ] El nombre del archivo es descriptivo

**Para archivos Word**:
- [ ] El documento se abre sin errores
- [ ] El formato visual se preserva
- [ ] Las tablas mantienen su estructura
- [ ] Los estilos están intactos

**Para archivos Excel**:
- [ ] Las fórmulas no modificadas siguen funcionando
- [ ] El formato de celdas se preserva
- [ ] No hay errores de referencia (#REF!)
- [ ] Las validaciones de datos siguen activas

**Para archivos de texto**:
- [ ] La sintaxis es válida (si es código/JSON/YAML/XML)
- [ ] La indentación se mantiene correcta
- [ ] No hay caracteres corruptos

#### Paso 4.2: Reporte al usuario

Proporciona un reporte conciso y técnico:

```
✅ Documento modificado exitosamente

Archivo: documento_actualizado.xlsx

Modificaciones realizadas:
• Celda B5: 1000 → 1500
• Celda B6: 800 → 1200
• Celda E10: "2024" → "2025"

Elementos preservados:
• Todas las fórmulas (50+)
• Formato de celdas y formato condicional
• Estructura de tablas y gráficos
• Validaciones de datos

[Ver documento actualizado](computer:///mnt/user-data/outputs/documento_actualizado.xlsx)
```

---

## TÉCNICAS AVANZADAS

### Técnica 1: Modificación de múltiples valores relacionados

Cuando varios valores deben cambiar en conjunto:

```python
# Excel: Modificaciones relacionadas
cambios_presupuesto = {
    'B5': 1500,      # Valor base
    'C5': 315,       # 1500 * 0.21 (IVA)
    'D5': 1815,      # Total
    'B10': 'Actualizado 2025'
}

for celda, valor in cambios_presupuesto.items():
    ws[celda] = valor
```

### Técnica 2: Preservación de formato numérico complejo

```python
# Excel: Copiar formato de celda antes de modificar
from copy import copy

celda_origen = ws['B5']
formato_original = copy(celda_origen.number_format)

# Modifica valor
celda_origen.value = 1500.75

# Restaura formato si fuera necesario (normalmente no hace falta)
# celda_origen.number_format = formato_original
```

### Técnica 3: Modificación condicional en texto

```python
# Para archivos de texto con múltiples instancias similares
contenido = documento.read()

# Usar expresiones regulares para modificación precisa
import re

# Cambiar solo la segunda aparición de un patrón
def reemplazar_n_ocurrencia(texto, patron, reemplazo, n=1):
    partes = re.split(patron, texto, maxsplit=n)
    if len(partes) > n:
        return patron.join(partes[:n]) + reemplazo + partes[n]
    return texto

# Ejemplo: cambiar solo el segundo "2024" en el documento
contenido_nuevo = reemplazar_n_ocurrencia(contenido, '2024', '2025', n=2)
```

### Técnica 4: Trabajo con plantillas que tienen marcadores

Si el documento original tiene marcadores para modificación:

```python
# Texto/Markdown con marcadores
contenido = plantilla.read()

marcadores = {
    '{{PRESUPUESTO}}': '1500',
    '{{YEAR}}': '2025',
    '{{CLIENTE}}': 'Empresa XYZ'
}

for marcador, valor in marcadores.items():
    contenido = contenido.replace(marcador, valor)

# Guarda
with open(salida, 'w') as f:
    f.write(contenido)
```

```python
# Word con marcadores
from docx import Document

doc = Document(plantilla_path)

for para in doc.paragraphs:
    if '{{' in para.text:
        for marcador, valor in marcadores.items():
            if marcador in para.text:
                para.text = para.text.replace(marcador, valor)

# Atención: esto puede perder formato de runs
# Mejor enfoque para preservar formato:
for para in doc.paragraphs:
    for run in para.runs:
        for marcador, valor in marcadores.items():
            if marcador in run.text:
                run.text = run.text.replace(marcador, valor)
```

---

## ERRORES COMUNES Y CÓMO EVITARLOS

### Error 1: Modificar más de lo necesario
❌ **MAL**:
```python
# Recrear todo el documento
nuevo_doc = Document()
# ... recrear todo desde cero
```

✅ **BIEN**:
```python
# Cargar y modificar solo lo necesario
doc = Document(plantilla)
doc.paragraphs[5].text = 'nuevo valor'
```

### Error 2: Perder formato al modificar texto
❌ **MAL**:
```python
# Word: perder los runs
para.text = 'nuevo texto'  # Esto elimina todo el formato de runs
```

✅ **BIEN**:
```python
# Modificar el run específico
for run in para.runs:
    if 'texto_original' in run.text:
        run.text = run.text.replace('texto_original', 'texto_nuevo')
```

### Error 3: No verificar unicidad en str_replace
❌ **MAL**:
```python
str_replace(
    old_str="2024",  # Puede aparecer 50 veces
    new_str="2025"
)
```

✅ **BIEN**:
```python
str_replace(
    old_str="Presupuesto anual para 2024 es de",
    new_str="Presupuesto anual para 2025 es de"
)
```

### Error 4: Modificar fórmulas sin necesidad
❌ **MAL**:
```python
# Excel: cambiar una fórmula que solo necesita datos actualizados
ws['C5'] = 1815  # Celda que tiene =B5*1.21
```

✅ **BIEN**:
```python
# Solo actualiza el dato base, la fórmula se recalcula sola
ws['B5'] = 1500  # C5 se recalculará automáticamente
```

### Error 5: No preservar encoding
❌ **MAL**:
```python
with open('documento.txt', 'r') as f:  # Sin encoding
    contenido = f.read()
```

✅ **BIEN**:
```python
with open('documento.txt', 'r', encoding='utf-8') as f:
    contenido = f.read()
```

---

## PATRONES DE USO COMUNES

### Patrón 1: Actualizar valores en informe financiero Excel

```python
from openpyxl import load_workbook

wb = load_workbook('informe_financiero.xlsx')
ws = wb['Resumen']

# Actualizar valores manteniendo fórmulas intactas
actualizaciones = {
    'B5': 150000,    # Ingresos Q1
    'B6': 180000,    # Ingresos Q2
    'B7': 165000,    # Ingresos Q3
    'B8': 195000,    # Ingresos Q4
    # B9 tiene =SUM(B5:B8), se actualiza automáticamente
}

for celda, valor in actualizaciones.items():
    ws[celda] = valor

wb.save('/mnt/user-data/outputs/informe_actualizado.xlsx')
```

### Patrón 2: Actualizar fechas y nombres en documento Word

```python
from docx import Document

doc = Document('contrato_plantilla.docx')

# Buscar y reemplazar preservando formato
reemplazos = {
    'NOMBRE_CLIENTE': 'Empresa ABC S.L.',
    'FECHA_CONTRATO': '25 de octubre de 2025',
    'IMPORTE_TOTAL': '15.000 €'
}

for para in doc.paragraphs:
    for original, nuevo in reemplazos.items():
        if original in para.text:
            # Reemplazar en runs para preservar formato
            for run in para.runs:
                if original in run.text:
                    run.text = run.text.replace(original, nuevo)

# También revisar tablas
for tabla in doc.tables:
    for fila in tabla.rows:
        for celda in fila.cells:
            for para in celda.paragraphs:
                for original, nuevo in reemplazos.items():
                    if original in para.text:
                        for run in para.runs:
                            if original in run.text:
                                run.text = run.text.replace(original, nuevo)

doc.save('/mnt/user-data/outputs/contrato_completado.docx')
```

### Patrón 3: Actualizar configuración JSON

```python
import json

with open('config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

# Modificar valores específicos
config['database']['host'] = 'nuevo-servidor.com'
config['database']['port'] = 5432
config['api']['timeout'] = 30
config['version'] = '2.1.0'

with open('/mnt/user-data/outputs/config_actualizado.json', 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
```

### Patrón 4: Actualizar valores en markdown técnico

```python
# Leer markdown
with open('README.md', 'r', encoding='utf-8') as f:
    contenido = f.read()

# Actualizar valores específicos con contexto suficiente
actualizaciones = [
    ('Version: 1.0.0', 'Version: 1.1.0'),
    ('Released: 2024', 'Released: 2025'),
    ('Contributors: 5', 'Contributors: 8'),
]

for viejo, nuevo in actualizaciones:
    contenido = contenido.replace(viejo, nuevo)

# Guardar
with open('/mnt/user-data/outputs/README_actualizado.md', 'w', encoding='utf-8') as f:
    f.write(contenido)
```

---

## MEJORES PRÁCTICAS DE COMUNICACIÓN CON EL USUARIO

### Antes de modificar:

1. **Confirma tu comprensión**:
```
"Voy a modificar los siguientes elementos en tu documento:
• Celda B5: cambiar 1000 por 1500
• Párrafo 3: actualizar año de 2024 a 2025
• Mantendré intacto: formato, fórmulas, estilos y todo lo demás.
¿Procedo?"
```

2. **Si hay ambigüedad, pregunta**:
```
"El documento tiene '2024' en 3 ubicaciones diferentes:
1. Encabezado: 'Informe 2024'
2. Párrafo 5: 'presupuesto para 2024'
3. Pie de página: 'Copyright 2024'

¿Cuáles debo actualizar a 2025?"
```

### Durante la modificación:

3. **Informa si encuentras complicaciones**:
```
"He detectado que la celda C5 contiene una fórmula (=B5*1.21) que 
referencia la celda que voy a modificar. La fórmula se actualizará 
automáticamente con el nuevo valor. ¿Es esto lo esperado?"
```

### Después de modificar:

4. **Proporciona un resumen técnico**:
```
✅ Documento modificado exitosamente

Cambios aplicados:
• 3 valores numéricos actualizados
• 2 referencias de fecha cambiadas
• 15 fórmulas dependientes se actualizarán automáticamente

Elementos preservados:
• Formato de 100% de las celdas
• Estructura de 3 tablas
• Todas las validaciones de datos
• Gráficos y objetos incrustados

[Ver documento](computer:///mnt/user-data/outputs/...)
```

---

## CONSIDERACIONES ESPECIALES POR TIPO DE ARCHIVO

### DOCX (Word)
- **Estructura**: Document → Sections → Paragraphs → Runs
- **Formato en**: Runs (bold, italic, color, font)
- **Tablas**: Acceso mediante doc.tables[índice]
- **Preservación**: NO recrear párrafos, modificar runs existentes

### XLSX (Excel)
- **Estructura**: Workbook → Worksheets → Cells
- **Formato en**: Celdas (number_format, font, fill, border)
- **Fórmulas**: Se recalculan automáticamente al abrir
- **Preservación**: load_workbook() mantiene TODO automáticamente

### PPTX (PowerPoint)
- **Estructura**: Presentation → Slides → Shapes
- **Formato en**: Shapes (position, size, fill, text properties)
- **Texto en**: Shape.text_frame.text
- **Preservación**: Modificar text_frame sin recrear shape

### MD/TXT (Texto plano)
- **Estructura**: Líneas de texto
- **Formato**: Markdown syntax (preservar)
- **Modificación**: str_replace o manipulación de líneas
- **Preservación**: Mantener indentación, saltos de línea, encoding

### JSON/YAML (Configuración)
- **Estructura**: Objetos/diccionarios anidados
- **Formato**: Indentación (preserve indent en dump)
- **Modificación**: Acceso por clave
- **Preservación**: Mantener estructura y comentarios (YAML)

---

## RESUMEN EJECUTIVO: REGLAS DE ORO

1. **Lee COMPLETAMENTE antes de modificar** - Entiende el documento primero
2. **Identifica con PRECISIÓN QUIRÚRGICA** - Localiza exactamente qué cambiar
3. **Modifica EXCLUSIVAMENTE lo solicitado** - Ni más ni menos
4. **Preserva TODO lo demás** - Formato, estructura, fórmulas, estilos
5. **Verifica la UNICIDAD** - Especialmente para str_replace
6. **Usa las herramientas APROPIADAS** - Cada tipo de archivo tiene su método
7. **Valida INMEDIATAMENTE** - Confirma que funcionó
8. **Comunica CLARAMENTE** - Informa qué hiciste y qué preservaste

---

## ANTIPATRONES: QUÉ NUNCA HACER

❌ **NUNCA recrees un documento desde cero** cuando puedes modificar el existente
❌ **NUNCA modifiques elementos sin localizar su posición exacta primero**
❌ **NUNCA asumas que un valor aparece solo una vez** sin verificar
❌ **NUNCA pierdas formato** por comodidad en la implementación
❌ **NUNCA modifiques fórmulas** que solo necesitan datos actualizados
❌ **NUNCA ignores el encoding** de archivos de texto
❌ **NUNCA olvides copiar el resultado** a /mnt/user-data/outputs/

---

## FLUJO DE TRABAJO RESUMIDO

```
1. LEER documento completo
   ↓
2. IDENTIFICAR elementos a modificar (con precisión)
   ↓
3. PLANIFICAR método de edición apropiado
   ↓
4. VERIFICAR unicidad (si aplica)
   ↓
5. EJECUTAR modificación quirúrgica
   ↓
6. VALIDAR resultado inmediatamente
   ↓
7. COPIAR a /mnt/user-data/outputs/
   ↓
8. REPORTAR al usuario con detalle técnico
```

---

## SKILL ACTIVATION

Este skill se activa cuando detectes palabras clave como:
- "usa este documento como plantilla"
- "modifica solo [X] en el documento"
- "actualiza únicamente [Y]"
- "cambia [Z] pero mantén el resto"
- "edita estos valores sin tocar el formato"

Al activarse:
1. Lee este skill completamente antes de empezar
2. Sigue la metodología de 4 fases rigurosamente
3. Aplica las mejores prácticas para el tipo de archivo específico
4. Comunica con claridad técnica y precisión

---

**VERSIÓN**: 1.0.0  
**ÚLTIMA ACTUALIZACIÓN**: Octubre 2025  
**COMPATIBILIDAD**: Claude con acceso a computer use y herramientas de archivo