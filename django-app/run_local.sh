#!/bin/bash

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias si no están instaladas
pip install -r requirements.txt

# Ejecutar migraciones
python manage.py migrate

# Crear superuser si no existe
python manage.py shell -c "
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser creado: admin/admin123')
else:
    print('Superuser ya existe')
"

# Ejecutar servidor de desarrollo
echo "🚀 Iniciando servidor Django en http://localhost:8000"
echo "📧 Admin: http://localhost:8000/admin (admin/admin123)"
python manage.py runserver 0.0.0.0:8000 