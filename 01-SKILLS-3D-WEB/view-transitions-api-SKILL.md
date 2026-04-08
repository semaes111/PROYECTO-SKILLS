---
name: view-transitions-api
description: >
  View Transitions API — transiciones cinematicas entre estados DOM y paginas
  sin frameworks. Pseudo-elementos ::view-transition, startViewTransition(),
  view-transition-name, MPA cross-document transitions.
  Usar cuando: view transition, transicion entre paginas, page transition CSS,
  morph animation, SPA transition, MPA transition, startViewTransition.
triggers:
  - "View Transitions"
  - "startViewTransition"
  - "transicion entre paginas"
  - "page transition CSS"
  - "morph animation navegador"
type: reference
---

# View Transitions API — Transiciones Cinematicas entre Estados DOM

## Que Es

La View Transitions API permite crear transiciones animadas entre estados
del DOM (SPA) o entre paginas completas (MPA) de forma nativa, sin
frameworks ni JavaScript complejo. El navegador captura snapshots del
estado anterior y posterior, y anima entre ambos.

**Soporte**: Chrome 111+ (SPA), Chrome 126+ (MPA), Safari 18+

## Modelo Mental

```
1. Llamas a startViewTransition(callback)
2. El navegador captura screenshot del estado ACTUAL (old)
3. Se ejecuta tu callback (actualiza el DOM)
4. El navegador captura screenshot del estado NUEVO (new)
5. Anima de old → new con pseudo-elementos CSS
```

## Pseudo-Elementos Generados

```
::view-transition
├── ::view-transition-group(root)
│   └── ::view-transition-image-pair(root)
│       ├── ::view-transition-old(root)     ← Screenshot anterior
│       └── ::view-transition-new(root)     ← Screenshot nuevo
├── ::view-transition-group(hero-image)     ← Nombrados con view-transition-name
│   └── ::view-transition-image-pair(hero-image)
│       ├── ::view-transition-old(hero-image)
│       └── ::view-transition-new(hero-image)
```

## SPA — Transicion Basica

```javascript
// Transicion simple entre estados del DOM
document.startViewTransition(() => {
  // Actualizar el DOM aqui
  updateContent()
})

// Con async/await
document.startViewTransition(async () => {
  const data = await fetchNewContent()
  renderContent(data)
})
```

## SPA — Con Promesas para Control Total

```javascript
const transition = document.startViewTransition(() => {
  updateDOM()
})

// Fases de la transicion
transition.ready       // Promise: pseudo-elementos creados, listo para animar
transition.finished    // Promise: animacion completada, pseudo-elementos eliminados
transition.updateCallbackDone  // Promise: callback del DOM completado

// Ejemplo: esperar a que termine
await transition.finished
console.log('Transicion completada')

// Saltar la animacion
transition.skipTransition()
```

## CSS — Personalizar la Animacion

```css
/* Animacion por defecto: crossfade de 250ms */
/* Personalizar duracion y easing */
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 0.5s;
  animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Slide desde la derecha */
@keyframes slide-from-right {
  from { transform: translateX(100%); }
}
@keyframes slide-to-left {
  to { transform: translateX(-100%); }
}

::view-transition-old(root) {
  animation: slide-to-left 0.4s ease-in both;
}
::view-transition-new(root) {
  animation: slide-from-right 0.4s ease-out both;
}
```

## view-transition-name — Elementos Individuales

```css
/* Asignar nombres unicos a elementos para animarlos individualmente */
.hero-image {
  view-transition-name: hero;
}

.page-title {
  view-transition-name: title;
}

/* REGLA CRITICA: cada view-transition-name debe ser UNICO en la pagina */
/* Si dos elementos comparten nombre → la transicion falla silenciosamente */
```

```css
/* Animar el hero con morph (cambio de tamano/posicion) */
::view-transition-group(hero) {
  animation-duration: 0.6s;
  animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* El titulo hace slide up */
::view-transition-old(title) {
  animation: fade-out 0.3s ease-out;
}
::view-transition-new(title) {
  animation: slide-up 0.4s ease-out;
}
```

## MPA — Cross-Document Transitions

```css
/* En AMBAS paginas (origen y destino) */
@view-transition {
  navigation: auto;  /* Habilitar transiciones entre paginas */
}

/* Elementos que deben "morphear" entre paginas */
/* Pagina de lista */
.product-card-image {
  view-transition-name: product-hero;
}

/* Pagina de detalle */
.product-detail-image {
  view-transition-name: product-hero;  /* Mismo nombre = morph automatico */
}
```

```css
/* Personalizar transicion MPA */
::view-transition-old(root) {
  animation: fade-and-scale-out 0.3s ease-in;
}
::view-transition-new(root) {
  animation: fade-and-scale-in 0.4s ease-out;
}

@keyframes fade-and-scale-out {
  to { opacity: 0; transform: scale(0.95); }
}
@keyframes fade-and-scale-in {
  from { opacity: 0; transform: scale(1.05); }
}
```

## Tipos de Transicion MPA

```css
/* Detectar tipo de navegacion */
@view-transition {
  navigation: auto;
  types: slide, backwards;  /* Tipos custom */
}
```

```javascript
// En JavaScript, definir tipo segun la navegacion
window.addEventListener('pagereveal', (e) => {
  if (e.viewTransition) {
    // Determinar direccion
    const isBack = navigation.activation.navigationType === 'traverse'
    if (isBack) {
      e.viewTransition.types.add('backwards')
    }
  }
})
```

```css
/* CSS condicional por tipo */
::view-transition-old(root):active-view-transition-type(backwards) {
  animation: slide-from-left 0.4s ease;
}
::view-transition-new(root):active-view-transition-type(backwards) {
  animation: slide-to-right 0.4s ease;
}
```

## React / Next.js — SPA Integration

```tsx
// Hook para View Transitions en React
function useViewTransition() {
  const startTransition = (callback: () => void) => {
    if (!document.startViewTransition) {
      callback()  // Fallback sin animacion
      return
    }
    document.startViewTransition(callback)
  }
  return { startTransition }
}

// Uso en componente
function ProductList() {
  const [view, setView] = useState<'grid' | 'list'>('grid')
  const { startTransition } = useViewTransition()

  const toggleView = () => {
    startTransition(() => {
      setView(prev => prev === 'grid' ? 'list' : 'grid')
    })
  }

  return (
    <>
      <button onClick={toggleView}>Toggle View</button>
      <div className={view === 'grid' ? 'grid-view' : 'list-view'}>
        {products.map(p => <ProductCard key={p.id} product={p} />)}
      </div>
    </>
  )
}
```

```tsx
// Con flushSync para React (forzar update sincrono)
import { flushSync } from 'react-dom'

function navigateTo(newContent: React.ReactNode) {
  document.startViewTransition(() => {
    flushSync(() => {
      setContent(newContent)  // React actualiza sincronamente
    })
  })
}
```

## Patron: Card-to-Detail Morph

```css
/* Lista de cards */
.card-image {
  view-transition-name: var(--card-vt-name);  /* Dinamico via JS */
}

/* Pagina de detalle */
.detail-hero {
  view-transition-name: card-hero;
}

/* Animar el morph */
::view-transition-group(card-hero) {
  animation-duration: 0.5s;
  animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}
```

```javascript
// Asignar nombres dinamicos antes de transicionar
function navigateToDetail(cardElement, productId) {
  cardElement.style.viewTransitionName = 'card-hero'

  document.startViewTransition(async () => {
    await loadDetailPage(productId)
    // El elemento de detalle ya tiene view-transition-name: card-hero
  })
}
```

## Patron: Theme Toggle con View Transition

```javascript
function toggleTheme() {
  const transition = document.startViewTransition(() => {
    document.documentElement.classList.toggle('dark')
  })

  // Animacion circular desde el boton
  transition.ready.then(() => {
    const { x, y } = themeButton.getBoundingClientRect()
    const cx = x + themeButton.offsetWidth / 2
    const cy = y + themeButton.offsetHeight / 2
    const radius = Math.hypot(
      Math.max(cx, window.innerWidth - cx),
      Math.max(cy, window.innerHeight - cy)
    )

    document.documentElement.animate(
      { clipPath: [
        `circle(0px at ${cx}px ${cy}px)`,
        `circle(${radius}px at ${cx}px ${cy}px)`
      ]},
      { duration: 500, easing: 'ease-in-out',
        pseudoElement: '::view-transition-new(root)' }
    )
  })
}
```

## Deteccion y Fallback

```javascript
// Feature detection
if ('startViewTransition' in document) {
  // Usar View Transitions API
} else {
  // Fallback: cambio instantaneo o animacion manual
}
```

```css
/* Solo aplicar estilos de transicion si hay soporte */
@supports (view-transition-name: test) {
  .element {
    view-transition-name: my-element;
  }
}
```

## Accesibilidad

```css
/* SIEMPRE respetar prefer-reduced-motion */
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation-duration: 0.001s !important;
  }
}
```

## Performance

- Las transiciones usan snapshots rasterizados → muy eficientes
- El navegador optimiza automaticamente (compositor thread)
- No hay re-layout durante la animacion
- `view-transition-name` en muchos elementos puede impactar → usar solo donde necesites
- MPA transitions requieren que la pagina destino cargue rapido

## Cuando Usar View Transitions vs Alternativas

| Caso | View Transitions | GSAP/Framer Motion |
|------|-----------------|-------------------|
| Cambio de pagina SPA | SI (nativo) | Posible pero mas codigo |
| MPA cross-document | SI (unico) | NO (imposible) |
| Morph entre layouts | SI (automatico) | Manual y complejo |
| Animaciones complejas con timeline | NO | GSAP |
| Soporte navegadores antiguos | NO | SI |
| Theme toggle cinematico | SI (elegante) | Posible |
