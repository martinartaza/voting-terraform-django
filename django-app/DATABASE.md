# 🗄️ Configuración de Base de Datos

## 📋 Archivos de Base de Datos

### `db.sqlite3.example`
- **Propósito**: Base de datos SQLite vacía con todas las tablas creadas
- **Uso**: Para desarrollo local rápido
- **Cómo usar**:
  ```bash
  cp db.sqlite3.example db.sqlite3
  ```

### `fixtures/initial_data.json`
- **Propósito**: Datos iniciales para desarrollo
- **Contiene**: Usuario administrador de ejemplo
- **Cómo usar**:
  ```bash
  python manage.py migrate
  python manage.py loaddata fixtures/initial_data.json
  ```

## 🚀 Configuración para Desarrollo Local

### Opción 1: Base de datos vacía
```bash
# Copiar base de datos ejemplo
cp db.sqlite3.example db.sqlite3

# Crear superuser
python manage.py createsuperuser
```

### Opción 2: Con datos iniciales
```bash
# Ejecutar migraciones
python manage.py migrate

# Cargar datos iniciales
python manage.py loaddata fixtures/initial_data.json
```

### Opción 3: Desde cero
```bash
# Ejecutar migraciones
python manage.py migrate

# Crear superuser manualmente
python manage.py createsuperuser
```

## 📝 Notas

- **Producción**: En Cloud Run se usa SQLite temporal que se recrea en cada deploy
- **Desarrollo**: Usa cualquiera de las opciones anteriores
- **Datos sensibles**: Nunca commitear `db.sqlite3` real con datos de producción

## 🔐 Credenciales por Defecto (solo desarrollo)

Si usas `initial_data.json`:
- **Usuario**: `admin`
- **Contraseña**: `admin123` (cambiar después del primer login)
- **Email**: `admin@example.com`