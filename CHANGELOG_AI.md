# CHANGELOG_AI - E.M.E Core Mobile

Relatório de desenvolvimento gerado por IA para o projeto EMECoreMobile.

---

## v1.2.2+9 — Correção das temperaturas Core e Package — 21/07/2026

### Arquivos modificados
- `lib/models/hardware_stats.dart` — adicionados campos separados para Core e Package, com compatibilidade para servidores antigos.
- `lib/pages/hardware_page.dart` — cada indicador passa a usar sua própria temperatura e cor.
- `README.md` — descrição do monitor atualizada.
- `pubspec.yaml` — versão atualizada para `1.2.2+9`.
- `../EMECore/src/EMECore.Hardware/Services/MobileServerService.cs` — protocolo passa a enviar `coreTemp` e `packageTemp`.
- `../EMECore/docs/hardware-project.md` — contrato do protocolo documentado.

### Resumo
O card de CPU do aplicativo mobile deixa de repetir a temperatura de Package nos indicadores `CORE` e `PKG`.

### Explicação detalhada
O servidor enviava somente `temp`, preenchido com a temperatura de Package. A interface Flutter reutilizava esse mesmo campo nas duas posições. O protocolo agora transmite os dois sensores separadamente, e o modelo mobile mantém fallback para `temp` ao se conectar a versões antigas do desktop.

### Motivo
Manter o monitor mobile consistente com os valores corretos já exibidos pelo desktop.

### Possíveis impactos
- O valor de `CORE` pode diferir de `PKG`, conforme os sensores reais da CPU.
- Clientes mobile antigos continuam funcionando porque o campo legado `temp` foi preservado.

---

## v1.2.1+8 — 21/07/2026

### Arquivos modificados
- `lib/widgets/gamepad_widget.dart` — correção da projeção vertical dos analógicos esquerdo e direito.
- `pubspec.yaml` — versão atualizada para `1.2.1+8`.
- `README.md` e `CHANGELOG_AI.md` — documentação da correção.
- `../docs/arquitetura/05-protocolo-mobile.md` — orientação sobre a conversão do eixo Y do XInput para a tela.

### Resumo
Os dois analógicos agora se movem na mesma direção física do controle no monitor mobile.

### Explicação detalhada
O desktop transmite os eixos do XInput sem alteração, onde valores positivos de Y representam movimento para cima. No sistema de coordenadas da interface Flutter, valores positivos de Y movem o elemento para baixo. A projeção visual passou a subtrair o deslocamento vertical, assim como já ocorre no monitor desktop.

### Motivo
Ao empurrar qualquer analógico para baixo, o indicador visual se deslocava para cima, e vice-versa.

### Possíveis impactos
A mudança afeta somente a posição visual dos indicadores dos analógicos. Os valores recebidos pelo WebSocket, os botões, os gatilhos e o protocolo permanecem inalterados.

## v1.2.0+7 — 21/07/2026

### Arquivos modificados
- `lib/pages/hardware_page.dart` — monitor reorganizado em cards recolhíveis e detalhes expansíveis.
- `lib/models/hardware_stats.dart` — modelos de informação e estado do gamepad.
- `lib/services/websocket_service.dart` — recepção da mensagem `gamepad_state`.
- `lib/widgets/gamepad_widget.dart` e `assets/gamepad/` — representação visual do controle.
- `lib/pages/connection_page.dart` — tentativa automática de reconexão ao último desktop.
- `pubspec.yaml`, `README.md` e `CHANGELOG_AI.md` — asset, versão e documentação atualizados.

### Resumo
O monitor mobile passa a apresentar mais informações em uma interface compacta e permite adicionar um módulo que acompanha o gamepad conectado ao desktop em tempo real.

### Explicação detalhada
- Cards de hardware podem ser recolhidos e seus detalhes expandidos.
- Ventoinhas são agrupadas com CPU, GPU ou placa-mãe conforme o nome do sensor.
- O módulo de controle recebe botões, gatilhos e analógicos pelo WebSocket.
- Streams, timers e subscriptions são cancelados no descarte da tela.

### Motivo
Alinhar o monitor mobile ao nível de informação do desktop e disponibilizar o acompanhamento de periféricos sem acesso direto ao PC.

### Possíveis impactos
- O gamepad em tempo real requer o desktop `2.23.0.0` ou superior.
- Em desktops antigos, o restante do monitor continua funcionando e o módulo de gamepad permanece sem atualização.

---

## v1.1.2 — 20/07/2026

### Arquivos modificados
- `lib/services/websocket_service.dart` — Novo metodo `_clearLastConnection()`; limpa host/porta salvos quando auto-reconnect falha (nunca conectou com sucesso)

### O que mudou
- Correcao de bug: reconexao automatica tentava porta salva incorreta (ex: 49500) infinitamente
- Quando a primeira conexao falha, `_clearLastConnection()` remove dados do SharedPreferences
- Evita loop de tentativas na porta errada

### Motivo
- SharedPreferences mantinha porta 49500 de sessao anterior, causando `Connection Refused` em toda inicializacao

---

## v1.1.0 — 18/07/2026

### Arquivos modificados
- `lib/theme/app_colors.dart` — Novo: paleta de cores centralizada alinhada com EMECore Desktop
- `lib/main.dart` — Tema atualizado com AppColors
- `lib/pages/hardware_page.dart` — Cores de cards (CPU/GPU/RAM/FPS/Disco/Rede/MB) do MonitorWindow
- `lib/pages/home_page.dart` — App bar e bottom nav com novas cores
- `lib/pages/connection_page.dart` — Tela de conexao com novas cores
- `lib/pages/games_page.dart` — Grid de jogos com novas cores
- `lib/pages/game_detail_page.dart` — Detalhe do jogo com novas cores
- `AGENTS.md` — Tabela de cores atualizada
- `README.md` — Tabela de cores atualizada

### O que mudou
- Paleta de cores agora espelha exatamente o EMECore Desktop (Design.cs + MonitorWindow.cs)
- Background: `#161719` → `#0A0B0D`
- Cards: `#1B2838` → `#2A2D31`
- Accent: `#66C0F4` → `#4CCBA0` (teal-green)
- Cores de hardware cards: CPU `#4ADE80`, GPU `#60A5FA`, RAM `#C084FC`, FPS `#FB923C`, Disco `#FBBF24`, Rede `#34D399`, MB `#F472B6`
- Todas as cores hardcoded substituidas por AppColors centralizado

---

## v1.0.2 — 18/07/2026

### Arquivos modificados
- `lib/pages/hardware_page.dart` — Timer periodico de 1s para atualizacao de hardware

### O que mudou
- Adicionado `Timer.periodic` de 1 segundo que solicita `get_hardware` continuamente enquanto a aba Hardware esta aberta
- Antes: dados eram solicitados apenas uma vez na abertura da pagina,resultando em dados estaticos

### Bug corrigido
- Hardware monitor nao atualizava em tempo real — so mostrava dados da primeira leitura

---

## v1.0.1 — 18/07/2026

### Arquivos modificados
- `android/app/src/main/AndroidManifest.xml` — Adicionado networkSecurityConfig e usesCleartextTraffic
- `android/app/src/main/res/xml/network_security_config.xml` — Novo: permite HTTP cleartext

### O que mudou
- Criado `network_security_config.xml` permitindo HTTP cleartext para redes locais
- Adicionado `android:networkSecurityConfig` e `android:usesCleartextTraffic="true"` no AndroidManifest
- Corrige problema onde Android bloqueava downloads de capas via HTTP do image server do PC

### Bug corrigido
- Capas de jogos não apareciam no app — Android bloqueava conexões HTTP para o servidor de imagens local (porta 8183)
- Causa: Android 9+ bloqueia HTTP cleartext por padrão. Sem network_security_config, o app não podia acessar `http://192.168.x.x:8183/`

---

## v1.0.0 — 17/07/2026

### Arquivos modificados
- `lib/main.dart`
- `lib/services/websocket_service.dart`
- `lib/services/discovery_service.dart`
- `lib/pages/connection_page.dart`
- `lib/pages/home_page.dart`
- `lib/pages/hardware_page.dart`
- `lib/pages/games_page.dart`
- `lib/pages/game_detail_page.dart`
- `lib/models/hardware_stats.dart`
- `lib/models/game.dart`
- `lib/models/achievement.dart`
- `pubspec.yaml`
- `README.md`
- `AGENTS.md`

### Resumo
Lancamento inicial do app Flutter de controle remoto para o E.M.E Core.

### Explicacao detalhada

**WebSocket Client (`websocket_service.dart`)**
- Cliente WebSocket com protocolo JSON bidirecional
- Auto-reconexao com contador de geracao para evitar callbacks obsoletos
- Timeout de 8 segundos na conexao com mensagem de erro clara
- Status so muda para `connected` apos receber `welcome` do servidor (corrige bug de navegacao)
- Streams para hardware stats, jogos, conquistas e erros
- Ping keep-alive a cada 30 segundos

**Auto-Discovery (`discovery_service.dart`)**
- Servico de descoberta automatica via UDP broadcast na porta 8182
- Escuta beacons do desktop (JSON com IP, porta, nome do PC)
- Lista de PCs atualizada em tempo real com cleanup automatico (10s timeout)
- Fallback para conexao manual (IP/Porta)

**Tela de Conexao (`connection_page.dart`)**
- Cards de PCs encontrados automaticamente na rede
- Toque para conectar — sem necessidade de digitar IP
- Secao de conexao manual colapsavel como fallback
- Exibicao de erros com estilo Steam (fundo vermelho, borda)

**Monitor de Hardware (`hardware_page.dart`)**
- CPU: uso, temperatura, voltagem, potencia
- GPU: uso, temperatura, hotspot, clock, memoria
- RAM: usada, total, livre, velocidade, modelo
- FPS: atual, min, max, media, 1% low, frame time
- Disco: leitura, escrita, uso
- Rede: download, upload
- Placa-mae: modelo, temperatura, BIOS
- Ventoinhas: nome, RPM, duty

**Biblioteca de Jogos (`games_page.dart`)**
- Grid estilo Steam com capas reais (Steam Store headers / Twitch box art)
- Busca por nome
- Filtro por plataforma (Todos/Steam/Xbox/Outros)
- Cards com nome, plataforma, tempo jogado

**Detalhe do Jogo (`game_detail_page.dart`)**
- Capa, nome, plataforma, genero, tempo, ultimo acesso
- Secao de conquistas com barras de progresso
- Botao de lancamento remoto

**Temas e Design**
- Dark theme Steam: `#161719`, `#1B2838`, `#66C0F4`, `#2A475E`
- Material Design com cards arredondados
- Icones e fontes do Material Design

### Motivos da mudanca
- Criar app mobile para complementar o desktop E.M.E Core
- Permitir monitoramento de hardware e lancamento de jogos remotamente
- Auto-discovery para eliminar necessidade de configurar IP manualmente

### Possiveis impactos
- Requer E.M.E Core v2.20.0+ rodando no PC com servidor WebSocket ativo
- Requer que celular e PC estejam na mesma rede WiFi
- UDP broadcast pode nao funcionar em redes com isolamento de clientes (AP isolation)
