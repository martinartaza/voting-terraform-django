#!/bin/bash

# Exit on any failure
set -e

# Run migrations
echo "Running migrations..."
python manage.py migrate

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create cache table (optional, for future use)
python manage.py createcachetable

# Create superuser if environment variables are provided
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]
then
    echo "Creating superuser..."
    python manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL
    echo "Superuser created successfully!"
else
    echo "Superuser environment variables not set. Skipping superuser creation."
fi

# Start the application
echo "Starting Django application..."
exec gunicorn --bind :8080 --workers 1 --threads 8 --timeout 0 config.wsgi:application