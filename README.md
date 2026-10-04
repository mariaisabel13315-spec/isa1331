# Isa creations RD

Tienda: https://isacreationsrd.web.app

Los archivos públicos de la tienda están en `public/`. Cada cambio en `main` publica la tienda mediante GitHub Actions, después de vincular Firebase una sola vez.

## Vinculación inicial

En Cloud Shell, con la cuenta propietaria del proyecto:

```bash
git clone https://github.com/mariaisabel13315-spec/isa1331.git isa-tienda-automatica
cd isa-tienda-automatica
firebase init hosting:github --project isa-creations-rd-13dfb
```

Seleccionar el repositorio `mariaisabel13315-spec/isa1331`, sin paso de compilación, publicación en `main`. La herramienta oficial guarda la credencial como secreto cifrado de GitHub, nunca en los archivos. Después guardar los workflows generados en GitHub y verificar la primera publicación.

No guardar contraseñas, tokens ni claves en este repositorio.
