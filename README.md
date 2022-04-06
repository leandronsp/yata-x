# Yata-X

Yet another web server written in Ruby, no frameworks included.

## Usage

1. Install gems
```bash
make install.gems
```

2. Setup and run PostgreSQL
```bash
make pg.server
make db.seed
```

3. Run the web server
```bash
make server
```

Then open `http://localhost:3000` and perform a login using:
```bash
email: user1@example.com
password: pass
```
