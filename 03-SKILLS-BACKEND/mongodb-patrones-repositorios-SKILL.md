---
name: MongoDB Patrones y Repositorios con TypeScript
description: Patrones avanzados para MongoDB con TypeScript usando el driver oficial, validación Zod, patrón repositorio genérico, pipelines de agregación, indexación, transacciones, change streams, optimistic locking y GridFS.
triggers: 
  - mongodb
  - typescript
  - repositorio
  - agregación
  - validación
  - transacciones
  - indexación
  - gridfs
---

# MongoDB Patrones y Repositorios con TypeScript

## 1. Introducción y Conceptos Fundamentales

MongoDB es una base de datos NoSQL orientada a documentos que escala horizontalmente. Con TypeScript podemos aprovechar la seguridad de tipos para evitar errores en tiempo de desarrollo. Este patrón utiliza el **driver oficial de MongoDB (npm package `mongodb`)** en lugar de Mongoose para máximo control y flexibilidad.

### ¿Por qué el driver oficial y no Mongoose?

- **Control total**: Acceso directo a APIs avanzadas como Change Streams y GridFS
- **Rendimiento**: Sin capas de abstracción innecesarias
- **Validación explícita**: Zod para esquemas en lugar de Mongoose schemas
- **Simplicidad**: Código más legible y predecible
- **Transacciones**: Soporte robusto con retry logic

---

## 2. Gestión de Conexión

### Configuración de URI y Client

```typescript
// config/mongodb.ts
import { MongoClient, ServerApiVersion } from 'mongodb';

export interface MongoConfig {
  uri: string;
  dbName: string;
  options?: {
    maxPoolSize?: number;
    minPoolSize?: number;
    maxIdleTimeMS?: number;
    serverSelectionTimeoutMS?: number;
  };
}

export class MongoDbConnection {
  private client: MongoClient | null = null;

  async connect(config: MongoConfig): Promise<MongoClient> {
    if (this.client?.topology?.isConnected()) {
      return this.client;
    }

    const mongoConfig = {
      serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true,
      },
      maxPoolSize: config.options?.maxPoolSize ?? 50,
      minPoolSize: config.options?.minPoolSize ?? 10,
      maxIdleTimeMS: config.options?.maxIdleTimeMS ?? 45000,
      serverSelectionTimeoutMS: config.options?.serverSelectionTimeoutMS ?? 5000,
    };

    this.client = new MongoClient(config.uri, mongoConfig);
    await this.client.connect();
    console.log('✓ Conectado a MongoDB');
    return this.client;
  }

  async disconnect(): Promise<void> {
    if (this.client) {
      await this.client.close();
      this.client = null;
    }
  }

  getClient(): MongoClient {
    if (!this.client) {
      throw new Error('MongoDB no conectado');
    }
    return this.client;
  }

  getDatabase(dbName: string) {
    return this.getClient().db(dbName);
  }
}
```

### Pool Management y Reconnection

```typescript
// config/connection-pool.ts
import { Db, MongoClient } from 'mongodb';

export class ConnectionPool {
  private instances: Map<string, { client: MongoClient; db: Db }> = new Map();

  async getDatabase(
    connectionName: string,
    uri: string,
    dbName: string
  ): Promise<Db> {
    if (this.instances.has(connectionName)) {
      const instance = this.instances.get(connectionName)!;
      if (instance.client.topology?.isConnected()) {
        return instance.db;
      }
    }

    const client = new MongoClient(uri, {
      maxPoolSize: 50,
      serverSelectionTimeoutMS: 5000,
    });

    await client.connect();
    const db = client.db(dbName);

    this.instances.set(connectionName, { client, db });
    return db;
  }

  async closeAll(): Promise<void> {
    for (const [, instance] of this.instances) {
      await instance.client.close();
    }
    this.instances.clear();
  }
}
```

---

## 3. Validación de Esquemas con Zod

### Definición de Esquemas

```typescript
// schemas/user.schema.ts
import { z } from 'zod';
import { ObjectId } from 'mongodb';

export const UserSchema = z.object({
  _id: z.instanceof(ObjectId).optional(),
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['admin', 'user', 'moderator']),
  createdAt: z.date().optional(),
  updatedAt: z.date().optional(),
  version: z.number().int().default(1),
});

export const UserInsertSchema = UserSchema.omit({
  _id: true,
  createdAt: true,
  updatedAt: true,
  version: true,
});

export type User = z.infer<typeof UserSchema>;
export type UserInsert = z.infer<typeof UserInsertSchema>;

export const validateUser = (data: unknown): User => {
  return UserSchema.parse(data);
};

export const validateUserInsert = (data: unknown): UserInsert => {
  return UserInsertSchema.parse(data);
};
```

---

## 4. Patrón Repositorio Genérico con CRUD

### BaseRepository

```typescript
// repositories/base.repository.ts
import { Db, Collection, ObjectId, Filter, UpdateFilter, FindOptions } from 'mongodb';
import { ZodSchema } from 'zod';

export abstract class BaseRepository<T> {
  protected collection: Collection<T>;
  protected db: Db;

  constructor(db: Db, collectionName: string) {
    this.db = db;
    this.collection = db.collection(collectionName);
  }

  // CREATE
  async create(data: Omit<T, '_id'>): Promise<T> {
    const now = new Date();
    const doc = {
      ...data,
      createdAt: now,
      updatedAt: now,
      version: 1,
    } as any;

    const result = await this.collection.insertOne(doc);
    return { ...doc, _id: result.insertedId } as T;
  }

  async createMany(documents: Omit<T, '_id'>[]): Promise<T[]> {
    const now = new Date();
    const docs = documents.map(doc => ({
      ...doc,
      createdAt: now,
      updatedAt: now,
      version: 1,
    }));

    const result = await this.collection.insertMany(docs as any);
    return docs.map((doc, idx) => ({ ...doc, _id: result.insertedIds[idx] } as T));
  }

  // READ
  async findById(id: ObjectId | string): Promise<T | null> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    return this.collection.findOne({ _id: objectId } as Filter<T>);
  }

  async findOne(filter: Filter<T>): Promise<T | null> {
    return this.collection.findOne(filter);
  }

  async findMany(filter: Filter<T> = {}, options: FindOptions = {}): Promise<T[]> {
    return this.collection.find(filter, options).toArray();
  }

  async findPaginated(
    filter: Filter<T> = {},
    page: number = 1,
    limit: number = 10
  ): Promise<{ items: T[]; total: number; page: number; pages: number }> {
    const skip = (page - 1) * limit;
    const [items, total] = await Promise.all([
      this.collection.find(filter).skip(skip).limit(limit).toArray(),
      this.collection.countDocuments(filter),
    ]);

    return {
      items,
      total,
      page,
      pages: Math.ceil(total / limit),
    };
  }

  // UPDATE
  async updateById(id: ObjectId | string, data: Partial<T>): Promise<T | null> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    const result = await this.collection.findOneAndUpdate(
      { _id: objectId } as Filter<T>,
      {
        $set: { ...data, updatedAt: new Date() },
        $inc: { version: 1 },
      },
      { returnDocument: 'after' }
    );
    return result.value;
  }

  async updateMany(filter: Filter<T>, data: Partial<T>): Promise<number> {
    const result = await this.collection.updateMany(
      filter,
      {
        $set: { ...data, updatedAt: new Date() },
        $inc: { version: 1 },
      }
    );
    return result.modifiedCount;
  }

  // DELETE
  async deleteById(id: ObjectId | string): Promise<boolean> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    const result = await this.collection.deleteOne({ _id: objectId } as Filter<T>);
    return result.deletedCount > 0;
  }

  async deleteMany(filter: Filter<T>): Promise<number> {
    const result = await this.collection.deleteMany(filter);
    return result.deletedCount;
  }

  // COUNT
  async count(filter: Filter<T> = {}): Promise<number> {
    return this.collection.countDocuments(filter);
  }

  // AGGREGATE
  async aggregate<R = T>(pipeline: any[]): Promise<R[]> {
    return this.collection.aggregate(pipeline).toArray();
  }

  // EXISTS
  async exists(filter: Filter<T>): Promise<boolean> {
    const result = await this.collection.findOne(filter, { projection: { _id: 1 } });
    return result !== null;
  }
}
```

### Implementación Específica de Repositorio

```typescript
// repositories/user.repository.ts
import { Db, ObjectId } from 'mongodb';
import { BaseRepository } from './base.repository';
import { User } from '../schemas/user.schema';

export class UserRepository extends BaseRepository<User> {
  constructor(db: Db) {
    super(db, 'users');
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.findOne({ email } as any);
  }

  async findByRole(role: string): Promise<User[]> {
    return this.findMany({ role } as any);
  }

  async findActiveUsers(): Promise<User[]> {
    return this.findMany(
      { deletedAt: { $exists: false } } as any,
      { sort: { createdAt: -1 } }
    );
  }

  async incrementLoginCount(userId: ObjectId): Promise<void> {
    await this.collection.updateOne(
      { _id: userId },
      { $inc: { loginCount: 1 }, $set: { lastLogin: new Date() } }
    );
  }
}
```

---

## 5. Pipeline de Agregación

### Ejemplo: Analytics de Ventas

```typescript
// repositories/sales.repository.ts
export class SalesRepository extends BaseRepository<Sale> {
  constructor(db: Db) {
    super(db, 'sales');
  }

  async getSalesByProductAndMonth(): Promise<any[]> {
    return this.aggregate([
      // $match: Filtrar documentos
      {
        $match: {
          status: 'completed',
          createdAt: {
            $gte: new Date(new Date().getFullYear(), 0, 1),
          },
        },
      },

      // $lookup: JOIN con otra colección (tipo LEFT JOIN)
      {
        $lookup: {
          from: 'products',
          localField: 'productId',
          foreignField: '_id',
          as: 'product',
        },
      },

      // $unwind: Descongelar array (product pasa de array a objeto)
      { $unwind: '$product' },

      // $group: Agrupar y agregar
      {
        $group: {
          _id: {
            month: { $month: '$createdAt' },
            productName: '$product.name',
          },
          totalSales: { $sum: '$amount' },
          count: { $sum: 1 },
          avgAmount: { $avg: '$amount' },
        },
      },

      // $project: Seleccionar/transformar campos
      {
        $project: {
          _id: 0,
          month: '$_id.month',
          productName: '$_id.productName',
          totalSales: 1,
          count: 1,
          avgAmount: { $round: ['$avgAmount', 2] },
        },
      },

      // $sort: Ordenar
      { $sort: { month: 1, totalSales: -1 } },
    ]);
  }

  async getTopCustomersBySpending(limit: number = 10): Promise<any[]> {
    return this.aggregate([
      {
        $group: {
          _id: '$customerId',
          totalSpent: { $sum: '$amount' },
          orderCount: { $sum: 1 },
        },
      },
      {
        $lookup: {
          from: 'customers',
          localField: '_id',
          foreignField: '_id',
          as: 'customer',
        },
      },
      { $unwind: '$customer' },
      {
        $sort: { totalSpent: -1 },
      },
      { $limit: limit },
      {
        $project: {
          _id: 0,
          customerId: '$_id',
          customerName: '$customer.name',
          totalSpent: 1,
          orderCount: 1,
        },
      },
    ]);
  }
}
```

---

## 6. Estrategias de Indexación

### Crear y Gestionar Índices

```typescript
// services/index-manager.ts
import { Db } from 'mongodb';

export class IndexManager {
  constructor(private db: Db) {}

  async createIndexes(): Promise<void> {
    // Índice simple
    await this.db.collection('users').createIndex({ email: 1 }, { unique: true });

    // Índice compuesto
    await this.db
      .collection('orders')
      .createIndex({ customerId: 1, createdAt: -1 }, { name: 'idx_customer_date' });

    // Índice de texto
    await this.db
      .collection('products')
      .createIndex({ name: 'text', description: 'text' });

    // Índice TTL (auto-expira documentos)
    await this.db
      .collection('sessions')
      .createIndex({ createdAt: 1 }, { expireAfterSeconds: 3600 });

    // Índice parcial (solo documentos que cumplen condición)
    await this.db.collection('users').createIndex(
      { email: 1 },
      {
        partialFilterExpression: {
          isActive: true,
          role: { $in: ['admin', 'moderator'] },
        },
      }
    );

    // Índice sparse (ignora documentos sin el campo)
    await this.db
      .collection('users')
      .createIndex({ phone: 1 }, { sparse: true });

    console.log('✓ Índices creados');
  }

  async listIndexes(collection: string): Promise<void> {
    const indexes = await this.db.collection(collection).listIndexes().toArray();
    console.log(`Índices en ${collection}:`, indexes);
  }
}
```

---

## 7. Transacciones con Retry Logic

### Implementar Transacciones ACID

```typescript
// services/transaction.service.ts
import { MongoClient, ClientSession } from 'mongodb';

export class TransactionService {
  constructor(private client: MongoClient) {}

  async transferFunds(
    fromAccountId: string,
    toAccountId: string,
    amount: number,
    maxRetries: number = 3
  ): Promise<void> {
    let retries = 0;

    while (retries < maxRetries) {
      const session = this.client.startSession();

      try {
        await session.withTransaction(async () => {
          const db = this.client.db('banking');
          const accountsCol = db.collection('accounts');

          // Restar de cuenta origen
          const decrementResult = await accountsCol.updateOne(
            { _id: fromAccountId, balance: { $gte: amount } },
            { $inc: { balance: -amount } },
            { session }
          );

          if (decrementResult.modifiedCount === 0) {
            throw new Error('Fondos insuficientes o cuenta no encontrada');
          }

          // Sumar a cuenta destino
          await accountsCol.updateOne(
            { _id: toAccountId },
            { $inc: { balance: amount } },
            { session }
          );

          // Registrar transacción
          await db.collection('transactions').insertOne(
            {
              from: fromAccountId,
              to: toAccountId,
              amount,
              status: 'completed',
              timestamp: new Date(),
            },
            { session }
          );
        });

        break; // Éxito, salir del loop
      } catch (error: any) {
        retries++;

        // Errores transitorios
        if (error.hasErrorLabel('TransientTransactionError')) {
          if (retries < maxRetries) {
            console.log(`Reintentando transacción (intento ${retries})...`);
            continue;
          }
        }

        // Error no-transitorio
        throw error;
      } finally {
        await session.endSession();
      }
    }

    if (retries === maxRetries) {
      throw new Error(
        `Transacción fallida después de ${maxRetries} intentos`
      );
    }
  }

  async batchOperationWithTransaction(
    operations: Array<{ collection: string; op: 'insert' | 'update' | 'delete'; data: any }>
  ): Promise<void> {
    const session = this.client.startSession();

    try {
      await session.withTransaction(async () => {
        const db = this.client.db();

        for (const operation of operations) {
          const col = db.collection(operation.collection);

          if (operation.op === 'insert') {
            await col.insertOne(operation.data, { session });
          } else if (operation.op === 'update') {
            await col.updateOne(
              { _id: operation.data._id },
              { $set: operation.data },
              { session }
            );
          } else if (operation.op === 'delete') {
            await col.deleteOne({ _id: operation.data._id }, { session });
          }
        }
      });
    } finally {
      await session.endSession();
    }
  }
}
```

---

## 8. Change Streams - Cambios en Tiempo Real

### Listener de Cambios en Colección

```typescript
// services/change-stream.service.ts
import { ChangeStream, MongoClient } from 'mongodb';

export class ChangeStreamService {
  private streams: Map<string, ChangeStream> = new Map();

  constructor(private client: MongoClient) {}

  watchCollection<T>(
    collectionName: string,
    pipeline: any[] = [],
    onNext: (change: any) => Promise<void>,
    onError: (error: Error) => void
  ): () => void {
    const db = this.client.db();
    const collection = db.collection(collectionName);

    const changeStream = collection.watch(pipeline);
    this.streams.set(collectionName, changeStream);

    changeStream.on('change', async (change) => {
      try {
        await onNext(change);
      } catch (error: any) {
        onError(error);
      }
    });

    changeStream.on('error', onError);

    // Retornar función para cerrar el stream
    return () => {
      changeStream.close();
      this.streams.delete(collectionName);
    };
  }

  watchInserts(
    collectionName: string,
    onInsert: (doc: any) => Promise<void>
  ): () => void {
    return this.watchCollection(
      collectionName,
      [{ $match: { operationType: 'insert' } }],
      async (change) => {
        await onInsert(change.fullDocument);
      },
      (error) => console.error('Change Stream Error:', error)
    );
  }

  watchUpdates(
    collectionName: string,
    onUpdate: (doc: any, changes: any) => Promise<void>
  ): () => void {
    return this.watchCollection(
      collectionName,
      [{ $match: { operationType: 'update' } }],
      async (change) => {
        await onUpdate(change.fullDocument, change.updateDescription);
      },
      (error) => console.error('Change Stream Error:', error)
    );
  }

  watchDeletes(
    collectionName: string,
    onDelete: (docId: any) => Promise<void>
  ): () => void {
    return this.watchCollection(
      collectionName,
      [{ $match: { operationType: 'delete' } }],
      async (change) => {
        await onDelete(change.documentKey._id);
      },
      (error) => console.error('Change Stream Error:', error)
    );
  }

  closeAllStreams(): void {
    for (const [, stream] of this.streams) {
      stream.close();
    }
    this.streams.clear();
  }
}
```

### Ejemplo de Uso

```typescript
// app.ts
const changeStreamService = new ChangeStreamService(mongoClient);

// Escuchar inserciones de usuarios
const unwatch = changeStreamService.watchInserts('users', async (newUser) => {
  console.log('Nuevo usuario creado:', newUser.email);
  await emailService.sendWelcomeEmail(newUser.email);
});

// Para detener
unwatch();
```

---

## 9. Optimistic Locking con Version Fields

### Patrón Worker con Versiones

```typescript
// services/optimistic-lock.service.ts
import { Db, ObjectId } from 'mongodb';

export class OptimisticLockService {
  constructor(private db: Db) {}

  async updateWithLock<T extends { _id: ObjectId; version: number }>(
    collectionName: string,
    id: ObjectId | string,
    updateFn: (doc: T) => Partial<T>,
    maxRetries: number = 5
  ): Promise<T> {
    const objectId = typeof id === 'string' ? new ObjectId(id) : id;
    const collection = this.db.collection<T>(collectionName);

    let retries = 0;

    while (retries < maxRetries) {
      // 1. Leer documento actual
      const currentDoc = await collection.findOne({ _id: objectId } as any);

      if (!currentDoc) {
        throw new Error('Documento no encontrado');
      }

      // 2. Calcular cambios
      const updates = updateFn(currentDoc as T);
      const currentVersion = currentDoc.version || 0;

      // 3. Intentar actualizar con version check
      const result = await collection.updateOne(
        {
          _id: objectId,
          version: currentVersion,
        } as any,
        {
          $set: {
            ...updates,
            updatedAt: new Date(),
          },
          $inc: { version: 1 },
        }
      );

      // 4. Si se actualizó, retornar nuevo documento
      if (result.modifiedCount > 0) {
        const updated = await collection.findOne({ _id: objectId } as any);
        return updated as T;
      }

      // 5. Si no, reintentar
      retries++;
      console.log(`Conflicto de version, reintentando... (${retries}/${maxRetries})`);

      // Backoff exponencial
      await new Promise((resolve) => setTimeout(resolve, Math.pow(2, retries) * 100));
    }

    throw new Error(
      `No se pudo actualizar documento tras ${maxRetries} intentos`
    );
  }
}
```

### Ejemplo: Actualizar Balance de Cuenta

```typescript
// services/account.service.ts
const accountService = new OptimisticLockService(db);

async function addCredits(accountId: string, credits: number) {
  const updated = await accountService.updateWithLock(
    'accounts',
    accountId,
    (currentAccount) => ({
      balance: (currentAccount.balance || 0) + credits,
    })
  );

  return updated;
}
```

---

## 10. GridFS para Almacenamiento de Archivos Grandes

### Subir y Descargar Archivos

```typescript
// services/gridfs.service.ts
import { GridFSBucket, ObjectId, Db } from 'mongodb';
import { Readable } from 'stream';

export class GridFsService {
  private bucket: GridFSBucket;

  constructor(db: Db) {
    this.bucket = new GridFSBucket(db);
  }

  async uploadFile(
    filename: string,
    fileStream: Readable,
    metadata?: Record<string, any>
  ): Promise<ObjectId> {
    return new Promise((resolve, reject) => {
      const uploadStream = this.bucket.openUploadStream(filename, {
        metadata,
      });

      fileStream.pipe(uploadStream);

      uploadStream.on('finish', () => {
        resolve(uploadStream.id);
      });

      uploadStream.on('error', reject);
      fileStream.on('error', reject);
    });
  }

  async downloadFile(fileId: ObjectId | string): Promise<Readable> {
    const objectId = typeof fileId === 'string' ? new ObjectId(fileId) : fileId;
    return this.bucket.openDownloadStream(objectId);
  }

  async deleteFile(fileId: ObjectId | string): Promise<void> {
    const objectId = typeof fileId === 'string' ? new ObjectId(fileId) : fileId;
    await this.bucket.delete(objectId);
  }

  async getFileInfo(fileId: ObjectId | string): Promise<any> {
    const objectId = typeof fileId === 'string' ? new ObjectId(fileId) : fileId;
    const files = await this.bucket.find({ _id: objectId }).toArray();
    return files[0] || null;
  }

  async listFiles(query?: Record<string, any>): Promise<any[]> {
    return this.bucket.find(query || {}).toArray();
  }
}
```

### Uso en API REST

```typescript
// routes/files.routes.ts
import express from 'express';
import { GridFsService } from '../services/gridfs.service';

export function setupFileRoutes(gridFs: GridFsService) {
  const router = express.Router();

  router.post('/upload', express.raw({ type: 'application/octet-stream' }), async (req, res) => {
    try {
      const filename = req.headers['x-filename'] as string;
      const fileId = await gridFs.uploadFile(filename, req);

      res.json({ fileId });
    } catch (error) {
      res.status(500).json({ error: 'Upload failed' });
    }
  });

  router.get('/download/:fileId', async (req, res) => {
    try {
      const stream = await gridFs.downloadFile(req.params.fileId);
      stream.pipe(res);
    } catch (error) {
      res.status(404).json({ error: 'File not found' });
    }
  });

  router.delete('/:fileId', async (req, res) => {
    try {
      await gridFs.deleteFile(req.params.fileId);
      res.json({ success: true });
    } catch (error) {
      res.status(500).json({ error: 'Delete failed' });
    }
  });

  return router;
}
```

---

## 11. Atlas Search para Búsqueda Full-Text

### Configurar y Usar Atlas Search

```typescript
// services/search.service.ts
import { Db } from 'mongodb';

export class SearchService {
  constructor(private db: Db) {}

  async searchProducts(query: string, limit: number = 10): Promise<any[]> {
    return this.db
      .collection('products')
      .aggregate([
        {
          $search: {
            text: {
              query,
              path: ['name', 'description', 'category'],
              fuzzy: {
                maxEdits: 2,
              },
            },
          },
        },
        {
          $project: {
            score: { $meta: 'searchScore' },
            name: 1,
            description: 1,
            price: 1,
          },
        },
        { $limit: limit },
      ])
      .toArray();
  }

  async searchWithFacets(
    query: string,
    facetField: string
  ): Promise<{ results: any[]; facets: any[] }> {
    const results = await this.db
      .collection('products')
      .aggregate([
        {
          $search: {
            text: {
              query,
              path: 'name',
            },
          },
        },
        {
          $facet: {
            results: [
              {
                $project: {
                  name: 1,
                  price: 1,
                  score: { $meta: 'searchScore' },
                },
              },
            ],
            facets: [
              {
                $group: {
                  _id: `$${facetField}`,
                  count: { $sum: 1 },
                },
              },
            ],
          },
        },
      ])
      .toArray();

    return {
      results: results[0].results,
      facets: results[0].facets,
    };
  }
}
```

---

## 12. Integración con Clean Architecture (Awilix DI)

### Configuración del Contenedor de DI

```typescript
// di/container.ts
import { createContainer, asClass, asValue, Lifetime } from 'awilix';
import { MongoDbConnection } from '../config/mongodb';
import { UserRepository } from '../repositories/user.repository';
import { IndexManager } from '../services/index-manager';
import { ChangeStreamService } from '../services/change-stream.service';
import { TransactionService } from '../services/transaction.service';

export function setupContainer() {
  const container = createContainer({
    injectionMode: 'CLASSIC',
  });

  // Config
  container.register({
    mongoConfig: asValue({
      uri: process.env.MONGODB_URI,
      dbName: process.env.MONGODB_DB_NAME,
    }),
  });

  // Connection
  container.register({
    mongoDbConnection: asClass(MongoDbConnection).singleton(),
  });

  // Services
  container.register({
    indexManager: asClass(IndexManager, {
      dependencies: ['db'],
    }).singleton(),
    changeStreamService: asClass(ChangeStreamService, {
      dependencies: ['mongoClient'],
    }).singleton(),
    transactionService: asClass(TransactionService, {
      dependencies: ['mongoClient'],
    }).singleton(),
  });

  // Repositories
  container.register({
    userRepository: asClass(UserRepository, {
      dependencies: ['db'],
    }),
  });

  return container;
}
```

### Usar en Controlador

```typescript
// controllers/user.controller.ts
export class UserController {
  constructor(private userRepository: UserRepository) {}

  async getUser(req, res) {
    const user = await this.userRepository.findById(req.params.id);
    res.json(user);
  }
}
```

---

## 13. Patrones de Migración

### Versiones de Migración Numeradas

```typescript
// migrations/001_create_indexes.ts
import { Db } from 'mongodb';

export const up = async (db: Db) => {
  await db.collection('users').createIndex({ email: 1 }, { unique: true });
  console.log('✓ Índice email creado');
};

export const down = async (db: Db) => {
  await db.collection('users').dropIndex('email_1');
  console.log('✓ Índice email eliminado');
};

// migrations/002_add_profile_fields.ts
export const up = async (db: Db) => {
  await db.collection('users').updateMany({}, {
    $set: {
      profile: {
        avatar: null,
        bio: '',
      },
      preferences: {
        theme: 'light',
        notifications: true,
      },
    },
  });
  console.log('✓ Campos de perfil añadidos');
};

export const down = async (db: Db) => {
  await db.collection('users').updateMany({}, {
    $unset: {
      profile: 1,
      preferences: 1,
    },
  });
};
```

### Migration Runner

```typescript
// services/migration.service.ts
import { Db } from 'mongodb';
import * as fs from 'fs';
import * as path from 'path';

export class MigrationService {
  constructor(private db: Db) {}

  async runPendingMigrations(migrationsDir: string): Promise<void> {
    const migrationsCollection = this.db.collection('migrations');

    const files = fs
      .readdirSync(migrationsDir)
      .filter((f) => f.match(/^\d+_.*\.ts$/))
      .sort();

    for (const file of files) {
      const migrationName = file.replace('.ts', '');
      const existing = await migrationsCollection.findOne({
        name: migrationName,
      });

      if (existing) {
        console.log(`✓ ${migrationName} ya ejecutada`);
        continue;
      }

      const migrationPath = path.join(migrationsDir, file);
      const migration = await import(migrationPath);

      try {
        await migration.up(this.db);
        await migrationsCollection.insertOne({
          name: migrationName,
          executedAt: new Date(),
        });
        console.log(`✓ ${migrationName} ejecutada`);
      } catch (error) {
        console.error(`✗ Error en ${migrationName}:`, error);
        throw error;
      }
    }
  }
}
```

---

## 14. Performance: Explain() e Índices

### Análisis de Queries

```typescript
// services/query-analyzer.ts
import { Db } from 'mongodb';

export class QueryAnalyzer {
  constructor(private db: Db) {}

  async explainQuery(
    collectionName: string,
    query: Record<string, any>,
    projection?: Record<string, any>
  ): Promise<void> {
    const collection = this.db.collection(collectionName);

    const plan = await collection
      .find(query)
      .project(projection)
      .explain('executionStats');

    console.log('Query Plan:');
    console.log(JSON.stringify(plan, null, 2));

    // Analizar
    const stats = plan.executionStats;
    console.log(`
      Documentos examinados: ${stats.totalDocsExamined}
      Documentos retornados: ${stats.nReturned}
      Eficiencia: ${((stats.nReturned / stats.totalDocsExamined) * 100).toFixed(2)}%
      Usa índice: ${stats.executionStages.stage !== 'COLLSCAN'}
    `);
  }

  async suggestIndexes(
    collectionName: string,
    frequentQueries: Record<string, any>[]
  ): Promise<void> {
    console.log(`\nSugerencias de índices para ${collectionName}:`);

    for (const query of frequentQueries) {
      const plan = await this.db
        .collection(collectionName)
        .find(query)
        .explain('executionStats');

      if (plan.executionStats.executionStages.stage === 'COLLSCAN') {
        const fields = Object.keys(query).join(', ');
        console.log(`  - Crear índice en: ${fields}`);
      }
    }
  }
}
```

### Optimización de Projections

```typescript
// Malo: Retorna todos los campos
const user = await userRepository.findById(userId);

// Bien: Solo campos necesarios
const result = await db
  .collection('users')
  .findOne({ _id: userId }, { projection: { name: 1, email: 1 } });
```

---

## 15. MongoDB vs PostgreSQL: Matriz de Decisión

| Aspecto | MongoDB | PostgreSQL |
|--------|---------|-----------|
| **Modelo de Datos** | Documentos flexibles (NoSQL) | Tablas rígidas (SQL) |
| **Esquema** | Flexible, sin esquema (o con validación) | Rígido, obligatorio |
| **Escalabilidad Horizontal** | Excelente (Sharding nativo) | Compleja (requiere tools) |
| **Transacciones ACID** | ✓ Multi-documento (4.0+) | ✓ Nativo |
| **Joins** | Caros, usa `$lookup` | Optimizados |
| **Consultas Complejas** | `$match`, `$group`, agregación | SQL JOIN, window functions |
| **Indexación Full-Text** | Atlas Search (premium) | Excelente nativo |
| **Caché** | No necesario (WiredTiger) | Necesario (Redis) |
| **Replicación** | Replica Sets | WAL + streaming |
| **Costos** | Medium-Alto (Atlas) | Bajo (open source) |
| **Use Case Ideal** | E-commerce, IoT, time-series | CRM, ERP, datos relacionales |

### Elegir MongoDB si:
- Datos con estructura variable
- Necesitas escalabilidad horizontal
- Prototipado rápido
- Análisis en tiempo real (agregaciones)

### Elegir PostgreSQL si:
- Datos altamente relacionales
- Necesitas garantías ACID estrictas
- Consultas complejas con JOINs
- Compliance/auditoría regulatoria

---

## 16. Checklist de Buenas Prácticas

- Usar el driver oficial de MongoDB, no Mongoose
- Validar inputs con Zod antes de insertar
- Crear índices apropiados (simple, compuesto, TTL, texto)
- Usar proyecciones para limitar campos
- Implementar paginación en resultados grandes
- Usar transacciones para operaciones multi-documento
- Monitorear con `explain()` y Atlas tools
- Implementar connection pooling
- Usar Change Streams para sincronización
- Aplicar Optimistic Locking en actualizaciones concurrentes
- Versionar esquemas con migraciones
- Usar GridFS para archivos > 16MB
- Monitorear índices no utilizados
- Implementar retry logic en transacciones

---

**Referencia**: [MongoDB Oficial](https://docs.mongodb.com) | [TypeScript Driver](https://mongodb.github.io/node-mongodb-native)
