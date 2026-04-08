---
name: fisicas-2d-3d-web
description: >
  Fisicas realistas para la web — Matter.js (2D) y Cannon-es (3D).
  Rigid bodies, constraints, collisions, gravedad, ragdolls.
  Integracion con Three.js via @react-three/cannon y @react-three/rapier.
  Usar cuando: fisicas web, Matter.js, Cannon, rigid body, collision,
  gravedad, ragdoll, fisicas 3D, @react-three/cannon, Rapier.
triggers:
  - "Matter.js"
  - "Cannon"
  - "fisicas web"
  - "rigid body"
  - "collision detection"
  - "@react-three/cannon"
  - "Rapier"
  - "ragdoll"
  - "gravedad web"
type: reference
---

# Fisicas 2D/3D para la Web — Matter.js + Cannon-es + Rapier

## Arquitectura

```
2D Fisicas:
  Matter.js → Canvas 2D / SVG / DOM elements

3D Fisicas:
  Cannon-es → Three.js (manual sync)
  @react-three/cannon → React Three Fiber (hooks)
  @react-three/rapier → React Three Fiber (hooks, mas moderno)
```

---

## Matter.js — Fisicas 2D

```bash
npm install matter-js
# Types: npm install @types/matter-js -D
```

### Setup Basico

```javascript
import Matter from 'matter-js'

const { Engine, Render, Runner, Bodies, Composite, Mouse, MouseConstraint } = Matter

// 1. Motor de fisicas
const engine = Engine.create({
  gravity: { x: 0, y: 1, scale: 0.001 },
})

// 2. Renderer (canvas)
const render = Render.create({
  element: document.getElementById('physics-container'),
  engine,
  options: {
    width: 800,
    height: 600,
    wireframes: false,        // Mostrar texturas
    background: '#0a0a0a',
  },
})

// 3. Crear cuerpos
const ground = Bodies.rectangle(400, 590, 800, 20, {
  isStatic: true,             // No se mueve
  render: { fillStyle: '#333' },
})

const box = Bodies.rectangle(400, 200, 80, 80, {
  restitution: 0.6,           // Rebote (0-1)
  friction: 0.1,              // Friccion
  density: 0.001,             // Densidad (masa)
  render: { fillStyle: '#ff6b6b' },
})

const circle = Bodies.circle(300, 100, 40, {
  restitution: 0.8,
  render: { fillStyle: '#4ecdc4' },
})

// Poligono custom
const polygon = Bodies.polygon(500, 100, 6, 40, {
  render: { fillStyle: '#45b7d1' },
})

// 4. Agregar al mundo
Composite.add(engine.world, [ground, box, circle, polygon])

// 5. Mouse interaction
const mouse = Mouse.create(render.canvas)
const mouseConstraint = MouseConstraint.create(engine, {
  mouse,
  constraint: { stiffness: 0.2, render: { visible: false } },
})
Composite.add(engine.world, mouseConstraint)

// 6. Correr
Render.run(render)
Runner.run(Runner.create(), engine)
```

### Constraints (Juntas)

```javascript
const { Constraint } = Matter

// Cuerda entre dos cuerpos
const rope = Constraint.create({
  bodyA: box,
  bodyB: circle,
  length: 150,
  stiffness: 0.02,  // Elasticidad
  render: { strokeStyle: '#ffffff', lineWidth: 2 },
})

// Anclar al punto fijo (pin joint)
const pin = Constraint.create({
  pointA: { x: 400, y: 50 },  // Punto fijo en el mundo
  bodyB: box,
  length: 100,
  stiffness: 0.9,
})

Composite.add(engine.world, [rope, pin])
```

### Collision Events

```javascript
Matter.Events.on(engine, 'collisionStart', (event) => {
  event.pairs.forEach(pair => {
    const { bodyA, bodyB } = pair
    console.log(`Colision: ${bodyA.label} ↔ ${bodyB.label}`)

    // Cambiar color al colisionar
    bodyA.render.fillStyle = '#ff0000'
    bodyB.render.fillStyle = '#ff0000'
  })
})

Matter.Events.on(engine, 'collisionEnd', (event) => {
  event.pairs.forEach(pair => {
    pair.bodyA.render.fillStyle = '#ff6b6b'
    pair.bodyB.render.fillStyle = '#4ecdc4'
  })
})
```

### Matter.js + React (DOM Elements)

```tsx
import { useEffect, useRef } from 'react'
import Matter from 'matter-js'

function PhysicsScene() {
  const sceneRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const engine = Matter.Engine.create()
    const runner = Matter.Runner.create()

    // Crear cuerpos (sin renderer — usamos DOM)
    const bodies: Matter.Body[] = []
    for (let i = 0; i < 20; i++) {
      const body = Matter.Bodies.circle(
        Math.random() * 800, -50,
        20 + Math.random() * 30,
        { restitution: 0.5 }
      )
      bodies.push(body)
    }

    const walls = [
      Matter.Bodies.rectangle(400, 610, 800, 20, { isStatic: true }),
      Matter.Bodies.rectangle(0, 300, 20, 600, { isStatic: true }),
      Matter.Bodies.rectangle(800, 300, 20, 600, { isStatic: true }),
    ]

    Matter.Composite.add(engine.world, [...bodies, ...walls])
    Matter.Runner.run(runner, engine)

    // Sincronizar con DOM elements
    const elements = bodies.map((body, i) => {
      const el = document.createElement('div')
      el.className = 'physics-ball'
      el.style.cssText = `
        position: absolute; border-radius: 50%;
        background: hsl(${i * 18}, 70%, 60%);
        width: ${body.circleRadius! * 2}px;
        height: ${body.circleRadius! * 2}px;
      `
      sceneRef.current?.appendChild(el)
      return el
    })

    // Update loop
    Matter.Events.on(engine, 'afterUpdate', () => {
      bodies.forEach((body, i) => {
        elements[i].style.transform = `translate(${body.position.x - body.circleRadius!}px, ${body.position.y - body.circleRadius!}px) rotate(${body.angle}rad)`
      })
    })

    return () => {
      Matter.Runner.stop(runner)
      Matter.Engine.clear(engine)
    }
  }, [])

  return <div ref={sceneRef} className="relative w-[800px] h-[600px] overflow-hidden bg-black" />
}
```

---

## Cannon-es — Fisicas 3D (ESM fork de cannon.js)

```bash
npm install cannon-es
# Para R3F: npm install @react-three/cannon
```

### Setup Manual con Three.js

```javascript
import * as THREE from 'three'
import * as CANNON from 'cannon-es'

// Mundo fisico
const world = new CANNON.World({
  gravity: new CANNON.Vec3(0, -9.82, 0),
})
world.broadphase = new CANNON.SAPBroadphase(world)

// Suelo fisico
const groundBody = new CANNON.Body({
  type: CANNON.Body.STATIC,
  shape: new CANNON.Plane(),
})
groundBody.quaternion.setFromEuler(-Math.PI / 2, 0, 0)
world.addBody(groundBody)

// Caja fisica
const boxBody = new CANNON.Body({
  mass: 1,
  shape: new CANNON.Box(new CANNON.Vec3(0.5, 0.5, 0.5)),
  position: new CANNON.Vec3(0, 5, 0),
})
world.addBody(boxBody)

// Visual Three.js
const boxMesh = new THREE.Mesh(
  new THREE.BoxGeometry(1, 1, 1),
  new THREE.MeshStandardMaterial({ color: '#ff6b6b' })
)
scene.add(boxMesh)

// Sincronizar en el loop
function animate() {
  world.step(1 / 60)

  // Copiar posicion/rotacion de fisicas a visual
  boxMesh.position.copy(boxBody.position as any)
  boxMesh.quaternion.copy(boxBody.quaternion as any)

  renderer.render(scene, camera)
  requestAnimationFrame(animate)
}
```

---

## @react-three/cannon — Hooks para R3F

```bash
npm install @react-three/cannon @react-three/fiber three
```

```tsx
import { Canvas } from '@react-three/fiber'
import { Physics, useBox, usePlane, useSphere, useSpring } from '@react-three/cannon'

function PhysicsScene() {
  return (
    <Canvas camera={{ position: [0, 5, 10] }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[5, 10, 5]} />

      <Physics
        gravity={[0, -9.82, 0]}
        defaultContactMaterial={{ restitution: 0.5, friction: 0.3 }}
      >
        <Ground />
        <Box position={[0, 5, 0]} />
        <Box position={[0.5, 8, 0]} />
        <Ball position={[-1, 6, 0]} />
      </Physics>
    </Canvas>
  )
}

// Suelo
function Ground() {
  const [ref] = usePlane(() => ({
    rotation: [-Math.PI / 2, 0, 0],
    type: 'Static',
  }))
  return (
    <mesh ref={ref} receiveShadow>
      <planeGeometry args={[50, 50]} />
      <meshStandardMaterial color="#333" />
    </mesh>
  )
}

// Caja con fisicas
function Box({ position }: { position: [number, number, number] }) {
  const [ref, api] = useBox(() => ({
    mass: 1,
    position,
    args: [1, 1, 1],           // Tamano del collider
    onCollide: (e) => {
      console.log('Colision!', e.contact.impactVelocity)
    },
  }))

  return (
    <mesh ref={ref} castShadow onClick={() => {
      // Aplicar impulso al hacer click
      api.applyImpulse([0, 5, 0], [0, 0, 0])
    }}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="#ff6b6b" />
    </mesh>
  )
}

// Esfera
function Ball({ position }: { position: [number, number, number] }) {
  const [ref] = useSphere(() => ({
    mass: 0.5,
    position,
    args: [0.5],  // Radio
  }))
  return (
    <mesh ref={ref} castShadow>
      <sphereGeometry args={[0.5, 32, 32]} />
      <meshStandardMaterial color="#4ecdc4" />
    </mesh>
  )
}
```

### API de Control (useBox, useSphere, etc.)

```tsx
const [ref, api] = useBox(() => ({
  mass: 1,
  position: [0, 5, 0],
}))

// Aplicar fuerzas
api.applyForce([0, 100, 0], [0, 0, 0])        // Fuerza continua
api.applyImpulse([0, 10, 0], [0, 0, 0])       // Impulso instantaneo
api.applyLocalForce([0, 100, 0], [0, 0, 0])   // Fuerza en espacio local
api.applyTorque([0, 10, 0])                    // Torque (rotacion)

// Setear directamente
api.position.set(0, 10, 0)
api.velocity.set(0, 0, 0)
api.rotation.set(0, Math.PI / 4, 0)
api.angularVelocity.set(0, 0, 0)
api.mass.set(2)

// Suscribirse a cambios (para UI reactiva)
const positionRef = useRef([0, 0, 0])
useEffect(() => {
  const unsubscribe = api.position.subscribe((pos) => {
    positionRef.current = pos
  })
  return unsubscribe
}, [])
```

---

## @react-three/rapier — Alternativa Moderna (WASM)

```bash
npm install @react-three/rapier
```

```tsx
import { Physics, RigidBody, CuboidCollider } from '@react-three/rapier'

function RapierScene() {
  return (
    <Canvas>
      <Physics gravity={[0, -9.82, 0]} debug>  {/* debug muestra colliders */}
        {/* Suelo */}
        <RigidBody type="fixed">
          <mesh position={[0, -0.5, 0]}>
            <boxGeometry args={[50, 1, 50]} />
            <meshStandardMaterial color="#333" />
          </mesh>
        </RigidBody>

        {/* Caja dinamica */}
        <RigidBody
          position={[0, 5, 0]}
          restitution={0.7}
          friction={0.5}
          onCollisionEnter={({ other }) => {
            console.log('Colision con:', other.rigidBodyObject?.name)
          }}
        >
          <mesh>
            <boxGeometry args={[1, 1, 1]} />
            <meshStandardMaterial color="#ff6b6b" />
          </mesh>
        </RigidBody>

        {/* Esfera con collider automatico */}
        <RigidBody colliders="ball" position={[2, 8, 0]}>
          <mesh>
            <sphereGeometry args={[0.5]} />
            <meshStandardMaterial color="#4ecdc4" />
          </mesh>
        </RigidBody>

        {/* Sensor (detecta sin colisionar) */}
        <CuboidCollider
          args={[5, 0.1, 5]}
          position={[0, 2, 0]}
          sensor
          onIntersectionEnter={() => console.log('Entro en zona!')}
        />
      </Physics>
    </Canvas>
  )
}
```

## Cuando Usar Cual

| Motor | Dimension | Bundle | Velocidad | Caso de uso |
|-------|-----------|--------|-----------|-------------|
| Matter.js | 2D | 80KB | Rapido | Landing pages, UI playful |
| Cannon-es | 3D | 120KB | Medio | Escenas 3D moderadas |
| Rapier | 2D/3D | 250KB WASM | Muy rapido | Juegos, muchos cuerpos |

## Performance Tips

- **Matter.js**: Limitar a ~200 cuerpos activos, usar `sleeping: true`
- **Cannon-es**: `SAPBroadphase` para muchos cuerpos, `allowSleep: true`
- **Rapier**: WASM nativo = 10x mas rapido que JS, soporta 5000+ cuerpos
- Todos: reducir iteraciones del solver si no necesitas precision
- Usar colliders simples (box, sphere) en vez de trimesh cuando posible
