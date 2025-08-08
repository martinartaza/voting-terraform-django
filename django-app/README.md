# 🚀 Django App para Cloud Run

Esta es la aplicación Django que se despliega en Google Cloud Run usando Terraform.

## 🏗️ Estructura del Proyecto

```
django-app/
├── config/                 # Configuración de Django
│   ├── settings.py        # Configuración principal
│   ├── urls.py            # URLs del proyecto
│   ├── wsgi.py            # WSGI application
│   └── asgi.py            # ASGI application
├── manage.py              # Script de gestión de Django
├── requirements.txt       # Dependencias Python
├── Dockerfile            # Imagen Docker
├── cloudbuild.yaml       # Configuración de Cloud Build
├── .dockerignore         # Archivos a excluir del build
├── run_local.sh          # Script para desarrollo local
└── venv/                 # Entorno virtual (no se incluye en Docker)
```

## 🚀 Desarrollo Local

### 1. Activar entorno virtual
```bash
source venv/bin/activate
```

### 2. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 3. Ejecutar migraciones
```bash
python manage.py migrate
```

### 4. Crear superuser (opcional)
```bash
python manage.py createsuperuser
```

### 5. Ejecutar servidor de desarrollo
```bash
python manage.py runserver
```

### 🎯 Script rápido
```bash
./run_local.sh
```

## 🐳 Docker

### Build local
```bash
docker build -t django-app .
```

### Ejecutar localmente
```bash
docker run -p 8080:8080 django-app
```

## ☁️ Despliegue en Cloud Run

### Build y deploy automático
```bash
gcloud builds submit --config=cloudbuild.yaml .
```

### Variables de entorno necesarias
- `DJANGO_SECRET_KEY`: Clave secreta de Django
- `DJANGO_DEBUG`: Modo debug (False en producción)
- `DB_HOST`: Host de la base de datos PostgreSQL
- `DB_PORT`: Puerto de la base de datos (5432)
- `DB_NAME`: Nombre de la base de datos
- `DB_USER`: Usuario de la base de datos
- `DB_PASSWORD`: Contraseña de la base de datos

## 📊 Características

- ✅ Django 5.2.5
- ✅ Base de datos PostgreSQL (Cloud SQL)
- ✅ Archivos estáticos con WhiteNoise
- ✅ Admin de Django funcional
- ✅ CSRF configurado para Cloud Run
- ✅ Gunicorn como servidor WSGI
- ✅ Docker optimizado para Cloud Run

## 🔧 Configuración

### CSRF Trusted Origins
Las URLs están pre-configuradas en `config/settings.py` para Cloud Run. Si la URL cambia, actualiza:

```python
CSRF_TRUSTED_ORIGINS = [
    'https://tu-nueva-url.run.app',
]
```

### Archivos estáticos
Los archivos estáticos se sirven con WhiteNoise y se recolectan automáticamente en el build de Docker.

### Base de datos
La aplicación está configurada para usar PostgreSQL en producción. Para desarrollo local, puedes:
1. Usar `db.sqlite3.example` como base de datos de ejemplo
2. Configurar PostgreSQL localmente con las mismas credenciales
3. Usar las variables de entorno para conectar a la base de datos remota

## 🚀 URLs

- **Home**: `/`
- **Admin**: `/admin/`

## 🔐 Credenciales por defecto

- **Usuario**: `admin`
- **Contraseña**: `admin123`
- **Email**: `admin@example.com` 