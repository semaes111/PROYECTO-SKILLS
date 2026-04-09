---
name: Inyección de Dependencias con Awilix
description: Guía completa de Awilix, un contenedor DI moderno para TypeScript/Node.js. Cubre conceptos fundamentales, ciclos de vida, arquitectura limpia, scopes, testing y comparación con alternativas.
triggers:
  - awilix
  - inyección de dependencias
  - dependency injection
  - DI container
  - IoC container
  - inversión de control
---

# Inyección de Dependencias con Awilix

## Qué es Awilix

**Awilix** es un contenedor ligero, flexible y poderoso de **inyección de dependencias** (Dependency Injection - DI) para Node.js y TypeScript. Permite gestionar las relaciones entre componentes sin acoplamiento fuerte, facilitando código más testeable, modular y mantenible.

A diferencia de decoradores complejos, Awilix utiliza configuración explícita, lo que lo hace predecible y fácil de depurar.

## Instalación

```bash
npm install awilix
# o con yarn
yarn add awilix
```

## Conceptos Fundamentales

### 1. Container (Contenedor)
El contenedor es el núcleo que mantiene todas las registraciones y resuelve dependencias.

```typescript
import { createContainer } from 'awilix';

const container = createContainer();
```

### 2. Registration (Registración)
Define cómo construir una dependencia:
- **asClass()**: registra un constructor de clase
- **asFunction()**: registra una función factory
- **asValue()**: registra un valor constante

```typescript
container.register({
  logger: asValue(console),
  database: asClass(Database).singleton(),
  userService: asClass(UserService).scoped(),
});
```

### 3. Resolution (Resolución)
Obtener instancias del contenedor:

```typescript
const userService = container.resolve('userService');
// o con tipado
const userService = container.resolve<UserService>('userService');
```

### 4. Lifetimes (Ciclos de Vida)
Define cuándo se crean y destroyen las instancias.

## Modos de Registración

### asClass() - Registrar Constructores

```typescript
class UserRepository {
  constructor(private db: Database) {}
}

container.register({
  userRepository: asClass(UserRepository).singleton(),
});
```

**Awilix inyecta automáticamente las dependencias por nombre de parámetro.**

### asFunction() - Funciones Factory

```typescript
const createLogger = () => {
  return {
    info: (msg: string) => console.log(`[INFO] ${msg}`),
    error: (msg: string) => console.error(`[ERROR] ${msg}`),
  };
};

container.register({
  logger: asFunction(createLogger).singleton(),
});
```

### asValue() - Valores Constantes

```typescript
container.register({
  config: asValue({
    port: 3000,
    apiUrl: 'https://api.example.com',
  }),
  env: asValue(process.env),
});
```

## Ciclos de Vida (Lifetimes)

### TRANSIENT (Transitorio)
Crea una **nueva instancia cada vez** que se resuelve.

```typescript
container.register({
  requestHandler: asClass(RequestHandler).transient(),
});

// Cada resolución crea una nueva instancia
const handler1 = container.resolve('requestHandler');
const handler2 = container.resolve('requestHandler');
// handler1 !== handler2
```

**Uso**: servicios stateful, contexto de request específico.

### SCOPED (De Ámbito)
Crea **una instancia por scope** (típicamente por request HTTP).

```typescript
container.register({
  userService: asClass(UserService).scoped(),
});

const scope = container.createScope();
const userService1 = scope.resolve('userService');
const userService2 = scope.resolve('userService');
// userService1 === userService2 (misma instancia en el mismo scope)
```

**Uso**: servicios de aplicación, repositorios de sesión.

### SINGLETON (Único)
Crea **una sola instancia para toda la vida del contenedor**.

```typescript
container.register({
  database: asClass(Database).singleton(),
  cache: asClass(Redis).singleton(),
});
```

**Uso**: conexiones de BD, servicios configuración, pools.

## Contenedores con Scope (Crucial para Web Apps)

Para cada request HTTP, crea un scope aislado:

```typescript
// En middleware Express/Next.js
app.use((req, res, next) => {
  // Crear scope para este request
  req.container = container.createScope();
  
  // Todas las dependencias scoped en este request usan la misma instancia
  const userService = req.container.resolve('userService');
  
  res.on('finish', () => {
    // Limpiar scope al finalizar request
    req.container.dispose();
  });
  
  next();
});
```

**Ventaja**: aislamiento de datos por request, sin memory leaks.

## Auto-loading de Módulos

Registra automáticamente módulos desde directorio:

```typescript
import { loadModules } from 'awilix';

container.loadModules([
  ['src/repositories/**/*.ts', { register: asClass, lifetime: 'singleton' }],
  ['src/services/**/*.ts', { register: asClass, lifetime: 'scoped' }],
  ['src/utils/**/*.ts', { register: asFunction, lifetime: 'transient' }],
]);
```

Usa el **nombre del archivo** como clave de registración:
- `userRepository.ts` → registrado como `userRepository`
- `getUserByIdUseCase.ts` → registrado como `getUserByIdUseCase`

## Integración con Arquitectura Limpia

### Estructura de Capas

```
src/
├── domain/              (Entidades, interfaces)
├── application/         (Use Cases / Servicios)
├── infrastructure/      (Repositorios, Servicios externos)
├── interface/          (Controllers, Presenters)
└── di/                 (Configuración DI)
```

### Registración por Capas

```typescript
// di/container.ts
import { createContainer, asClass } from 'awilix';

export const createAppContainer = () => {
  const container = createContainer();

  // INFRASTRUCTURE: SINGLETON
  // (conexiones, servicios externos, repositorios)
  container.register({
    database: asClass(PostgresDatabase).singleton(),
    userRepository: asClass(UserRepository).singleton(),
    emailService: asClass(SendgridEmailService).singleton(),
  });

  // APPLICATION: SCOPED
  // (use cases, servicios de aplicación)
  container.register({
    createUserUseCase: asClass(CreateUserUseCase).scoped(),
    getUserByIdUseCase: asClass(GetUserByIdUseCase).scoped(),
    loginUseCase: asClass(LoginUseCase).scoped(),
  });

  return container;
};
```

### Ejemplo Completo: User Use Case

```typescript
// domain/entities/User.ts
export interface User {
  id: string;
  email: string;
  name: string;
}

// infrastructure/repositories/UserRepository.ts
export class UserRepository {
  constructor(private database: Database) {}

  async save(user: User): Promise<void> {
    await this.database.query(
      'INSERT INTO users (id, email, name) VALUES ($1, $2, $3)',
      [user.id, user.email, user.name]
    );
  }

  async findById(id: string): Promise<User | null> {
    const result = await this.database.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }
}

// application/usecases/CreateUserUseCase.ts
export class CreateUserUseCase {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}

  async execute(email: string, name: string): Promise<User> {
    const user: User = {
      id: generateId(),
      email,
      name,
    };

    await this.userRepository.save(user);
    await this.emailService.sendWelcomeEmail(email);

    return user;
  }
}

// interface/controllers/UserController.ts
export class UserController {
  constructor(private createUserUseCase: CreateUserUseCase) {}

  async create(req: Request, res: Response) {
    const { email, name } = req.body;
    const user = await this.createUserUseCase.execute(email, name);
    res.json(user);
  }
}

// En Express middleware
app.use((req, res, next) => {
  req.container = container.createScope();
  next();
});

app.post('/users', (req, res) => {
  const controller = req.container.resolve('userController');
  controller.create(req, res);
});
```

## Testing con Awilix

### Mock de Dependencias

```typescript
describe('CreateUserUseCase', () => {
  let container: AwilixContainer;
  let useCase: CreateUserUseCase;

  beforeEach(() => {
    container = createContainer();

    // Mock repository
    const mockUserRepository = {
      save: jest.fn(),
      findById: jest.fn(),
    };

    // Mock service
    const mockEmailService = {
      sendWelcomeEmail: jest.fn(),
    };

    container.register({
      userRepository: asValue(mockUserRepository),
      emailService: asValue(mockEmailService),
      createUserUseCase: asClass(CreateUserUseCase).scoped(),
    });

    useCase = container.resolve('createUserUseCase');
  });

  test('debe crear usuario y enviar email', async () => {
    const mockRepository = container.resolve('userRepository');
    const mockEmail = container.resolve('emailService');

    await useCase.execute('test@example.com', 'Test User');

    expect(mockRepository.save).toHaveBeenCalled();
    expect(mockEmail.sendWelcomeEmail).toHaveBeenCalledWith(
      'test@example.com'
    );
  });
});
```

## Express + Next.js Integration

### Express Middleware

```typescript
import { AwilixContainer } from 'awilix';

declare global {
  namespace Express {
    interface Request {
      container: AwilixContainer;
    }
  }
}

export const diMiddleware = (container: AwilixContainer) => {
  return (req: Request, res: Response, next: NextFunction) => {
    req.container = container.createScope();

    res.on('finish', () => {
      req.container.dispose();
    });

    next();
  };
};

app.use(diMiddleware(container));
```

### Next.js API Routes

```typescript
// pages/api/users.ts
import { createContainer, asClass } from 'awilix';

const container = createContainer();
container.register({
  userRepository: asClass(UserRepository).singleton(),
  createUserUseCase: asClass(CreateUserUseCase).scoped(),
});

export default async (req: NextApiRequest, res: NextApiResponse) => {
  const scope = container.createScope();

  try {
    const useCase = scope.resolve('createUserUseCase');
    const user = await useCase.execute(req.body.email, req.body.name);
    res.json(user);
  } finally {
    scope.dispose();
  }
};
```

## Comparación: Awilix vs Alternativas

| Criterio | Awilix | Tsyringe | Inversify | TypeDI |
|----------|--------|----------|-----------|--------|
| **Decoradores** | Opcionales | Requeridos | Requeridos | Requeridos |
| **Explicitness** | Muy explícito | Implícito | Implícito | Implícito |
| **Curva aprendizaje** | Baja | Media | Alta | Media |
| **Performance** | Excelente | Bueno | Bueno | Bueno |
| **Scopes/Lifecycles** | Completos | Básicos | Completos | Completos |
| **Tamaño bundle** | Muy pequeño | Pequeño | Medio | Pequeño |
| **Comunidad** | Activa | Activa | Grande | Activa |
| **Reflect Metadata** | No requiere | Requiere | Requiere | Requiere |

**Awilix gana en**: simplicidad, rendimiento, control explícito.

## Anti-patterns a Evitar

### Service Locator (ANTI-PATTERN)

```typescript
// ❌ MAL: Pasar container a todas partes
export class UserController {
  constructor(private container: AwilixContainer) {}

  async create(req: Request, res: Response) {
    const useCase = this.container.resolve('createUserUseCase');
    // Oculta dependencias reales
  }
}

// ✅ BIEN: Inyectar dependencias directas
export class UserController {
  constructor(private createUserUseCase: CreateUserUseCase) {}

  async create(req: Request, res: Response) {
    // Dependencias claras y explícitas
  }
}
```

### Dependencias Circulares

```typescript
// ❌ MAL: A depende de B, B depende de A
export class UserService {
  constructor(private orderService: OrderService) {}
}

export class OrderService {
  constructor(private userService: UserService) {}
}

// ✅ BIEN: Refactorizar hacia una dependencia común
export class TransactionService {
  constructor(
    private userRepository: UserRepository,
    private orderRepository: OrderRepository
  ) {}
}
```

### God Container

```typescript
// ❌ MAL: Un container global que sabe de todo
const globalContainer = createContainer();
// registra 50+ dependencias...

// ✅ BIEN: Modular por dominio
export const createUserDomainContainer = () => {
  const container = createContainer();
  container.register({
    userRepository: asClass(UserRepository).singleton(),
    createUserUseCase: asClass(CreateUserUseCase).scoped(),
  });
  return container;
};
```

### No Limpiar Scopes

```typescript
// ❌ MAL: Memory leak en request
app.use((req, res, next) => {
  req.container = container.createScope();
  next();
  // Scope nunca se destruye
});

// ✅ BIEN: Limpiar explícitamente
app.use((req, res, next) => {
  req.container = container.createScope();
  res.on('finish', () => req.container.dispose());
  next();
});
```

## Mejores Prácticas

1. **Explicitness over Magic**: Define registraciones claras en un archivo dedicado
2. **Scopes para Request**: Crea un scope por request HTTP en aplicaciones web
3. **Lifetime Correcto**: SINGLETON para servicios stateless, SCOPED para contexto
4. **Testing First**: Diseña con testabilidad en mente, sin containers en producción
5. **Modular**: Organiza registraciones por feature/dominio, no un único archivo
6. **Type Safety**: Aprovecha TypeScript para validar en compilación
7. **Documentation**: Documenta por qué existe cada dependencia

## Recursos

- [Documentación oficial](https://github.com/talyssonoc/awilix)
- [API Reference](https://awilix.netlify.app/)
- Clean Architecture: patrón recomendado para Awilix

---

**Versión**: 1.0 | **Última actualización**: 2026
