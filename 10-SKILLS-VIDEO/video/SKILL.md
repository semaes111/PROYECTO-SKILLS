---
name: video
description: Super-skill router para producción de vídeo. Selecciona herramientas instaladas según material de partida, calidad, infraestructura, licencia y aprobación humana. No instala automáticamente motores pesados ni consume APIs sin autorización.
license: router propio; cada adaptador conserva su licencia
---
# $video — router superior

## Principio
Decidir primero; ejecutar después. Detectar entorno, presupuesto, material de partida y restricciones de publicación.

## Árbol
- Vídeo largo existente → `clipify-es-pro`.
- Vídeo terminado, solo subtítulos → pycaps o Remotion según control requerido.
- Idea/guion, volumen alto → MoneyPrinterTurbo en contenedor aislado y versión fijada.
- Producción premium agéntica → OpenMontage, tras revisar AGPL y proveedores.
- Avatar → adaptador de avatar actual, GPU/API y consentimiento; no fijar InfiniteTalk como opción permanente.
- B-roll generativo local → solo con GPU compatible; en ausencia, stock licenciado o API aprobada.

## Puerta de infraestructura
Ejecutar `references/environment-check.sh`. No usar nombres de servidores ni capacidades hardcodeadas.

## Controles
1. Licencia del repo, modelos y activos.
2. Claves separadas, límites de gasto y autorización antes de usar API.
3. Versiones/digests fijados; nunca `latest` en producción.
4. Validación audiovisual y manifiesto de procedencia.
5. Aprobación humana obligatoria para contenido médico, avatar o publicación externa.

## Invocación
`$video <objetivo>` y el router devuelve: herramienta elegida, razón, requisitos, riesgos y pipeline. Solo ejecuta tras tener recursos y permisos suficientes.
