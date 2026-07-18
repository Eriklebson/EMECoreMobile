<div align="center">

# E.M.E Core Mobile

**App Flutter de controle remoto para o E.M.E Core — monitore hardware, gerencie jogos e lance jogos diretamente do celular.**

[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Android-16-3DDC84?logo=android)](https://developer.android.com/)
[![License](https://img.shields.io/badge/Licenca-MIT-green)](LICENSE)

</div>

---

## Funcionalidades

| Recurso | Descricao | Status |
|---------|-----------|--------|
| **Auto-Discovery** | Detecta PCs na rede automaticamente via UDP broadcast — sem digitar IP | ✅ |
| **Monitor de Hardware** | CPU, GPU, RAM, FPS, disco, rede, placa-mae em tempo real | ✅ |
| **Biblioteca de Jogos** | Grid com capas Steam/Twitch, busca por nome, filtros por plataforma | ✅ |
| **Lancamento Remoto** | Inicie jogos do celular direto no PC | ✅ |
| **Conquistas** | Visualize conquistas e progresso dos jogos | ✅ |
| **Conexao Manual** | Fallback com IP/Porta para redes sem broadcast | ✅ |
| **Dark Theme** | Tema escuro inspirado no Steam | ✅ |
| **Reconexao** | Reconexao automatica com tentativas limitadas | ✅ |

---

## Pre-requisitos

### Para usar
- App **E.M.E Core** v2.20.0+ rodando no PC (Windows)
- Celular Android na **mesma rede WiFi** do PC
- Ambos conectados a mesma rede (ex: `192.168.0.x`)

### Para compilar
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.44+)
- Android SDK (platform-tools, build-tools, platforms;android-36)
- USB Debugging habilitado no celular (Depuracao USB + Instalacao via USB no Xiaomi)

---

## Instalacao

### Usar APK pronto

1. Baixe o APK na aba **Releases** do GitHub
2. Instale no celular (ative "Fontes desconhecidas" se necessario)
3. Abra o app desktop E.M.E Core no PC
4. Abra o app no celular — o PC sera detectado automaticamente

### Compilar do codigo

```bash
# 1. Clone o repositorio
git clone https://github.com/Eriklebson/EMECoreMobile.git
cd EMECoreMobile

# 2. Instale dependencias
flutter pub get

# 3. Build debug
flutter build apk --debug

# 4. Instale no celular (com USB conectado)
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## Como usar

### Auto-Discovery (recomendado)

1. Abra o **E.M.E Core** no PC
2. Abra o **E.M.E Core Mobile** no celular
3. O app procura PCs na rede automaticamente
4. Toque no card do PC para conectar
5. Pronto — hardware, jogos e conquistas aparecem na tela

### Conexao manual

Se o auto-discovery nao funcionar:

1. Na tela de conexao, toque em **Conexao manual (IP/Porta)**
2. Digite o IP do PC (ex: `192.168.0.102`) e a porta (`8181`)
3. Toque em **Conectar manualmente**

---

## Arquitetura

```
EMECoreMobile/
├── lib/
│   ├── main.dart                    # Entry point, tema escuro
│   ├── models/
│   │   ├── hardware_stats.dart      # CPU/GPU/RAM/FPS/Disco/Rede/MB
│   │   ├── game.dart                # Modelo de jogo
│   │   └── achievement.dart         # Conquistas com progresso
│   ├── services/
│   │   ├── websocket_service.dart   # Cliente WebSocket + protocolo JSON
│   │   └── discovery_service.dart   # Auto-discovery via UDP broadcast
│   └── pages/
│       ├── connection_page.dart     # Tela de conexao (auto + manual)
│       ├── home_page.dart           # Navegacao principal (HW/Games)
│       ├── hardware_page.dart       # Monitor em tempo real
│       ├── games_page.dart          # Biblioteca de jogos
│       └── game_detail_page.dart    # Detalhe + conquistas
└── android/
```

---

## Protocolo WebSocket

Comunicacao JSON bidirecional entre desktop (servidor) e mobile (cliente).

### Desktop → Mobile

| Tipo | Descricao |
|------|-----------|
| `welcome` | Mensagem de boas-vindas apos conexao |
| `hardware_stats` | Stats de hardware a cada 1s |
| `game_list` | Lista de jogos com capas |
| `achievements` | Conquistas de um jogo |
| `game_launched` | Confirmacao de lancamento |
| `pong` | Resposta ao ping |

### Mobile → Desktop

| Tipo | Parametros | Descricao |
|------|-----------|-----------|
| `get_hardware` | — | Solicita stats de hardware |
| `get_games` | — | Solicita lista de jogos |
| `launch_game` | `gameId` | Lanca um jogo |
| `get_achievements` | `gameId` | Solicita conquistas |
| `ping` | — | Keep-alive (a cada 30s) |

### UDP Beacon (porta 8182)

O desktop envia broadcast UDP a cada 2 segundos:

```json
{
  "app": "EMECore",
  "ip": "192.168.0.102",
  "port": 8181,
  "name": "NomeDoPC"
}
```

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| UI | Flutter + Material Design |
| WebSocket | `web_socket_channel` v3.0.0 |
| Discovery | `dart:io` RawDatagramSocket (UDP) |
| State | Streams + StreamController |
| Protocolo | JSON |

---

## Tema

Dark theme inspirado no Steam:

| Elemento | Cor |
|----------|-----|
| Background | `#161719` |
| Surface/Cards | `#1B2838` |
| Accent | `#66C0F4` |
| Border | `#2A475E` |
| Text Muted | `#8F98A0` |
| Error | `#D94040` |

---

## Autor

**Eriklebson** — [GitHub](https://github.com/Eriklebson)

Parte do projeto **E.M.E Core**: [github.com/Eriklebson/EMECore](https://github.com/Eriklebson/EMECore)
