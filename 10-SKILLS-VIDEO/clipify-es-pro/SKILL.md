---
name: clipify-es-pro
description: Convierte vídeo largo en clips verticales en español con selección semántica, reencuadre, detección aproximada de hablante y subtítulos ASS. Usar para podcast, entrevista, webinar, consulta educativa o contenido médico. Requiere aprobación humana antes de publicar.
license: MIT; fork adaptado de louisedesadeleer/clipify
---
# Clipify ES Pro

## Perfiles
- `clinico`: precisión, contexto suficiente, sin claims recortados de forma engañosa.
- `educativo`: problema, explicación y conclusión autónoma.
- `viral`: tensión, sorpresa, dato o cambio de creencia.
- `humor`: punchline y reacción.

## Flujo obligatorio
1. Ejecutar `probe_media.py`; nunca asumir FPS, resolución o rotación.
2. Transcribir en el idioma real con timestamps de palabra.
3. Proponer candidatos con inicio y final semánticamente completos.
4. Detectar cortes de escena. Si cambian los planos, no usar ROIs fijas sin advertirlo.
5. Reencuadrar según dimensiones calculadas. `videotoolbox` solo en macOS; CUDA solo si está disponible.
6. Generar subtítulos con `build_ass.py`.
7. Validar con `ffprobe`, `volumedetect` y muestreo de fotogramas.
8. Guardar manifiesto JSON: fuente, timestamps, perfil, hook, CTA, advertencias y estado de aprobación.

## Reglas médicas y jurídicas
- No aislar una frase que cambie su significado clínico.
- No publicar recomendaciones individualizadas como universales.
- No publicar rostros o voces sin consentimiento/licencia.
- Estado inicial: `approval_required: true`.
