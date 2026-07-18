# E.M.E Core — Descricao das Telas

Descricao de cada tela do desktop (EMECore) e mobile (EMECoreMobile) para uso em site de apresentacao.

---

## Desktop — E.M.E Core (Windows)

### 1. Biblioteca de Jogos
**Arquivo:** `desktop/01-biblioteca-jogos.png`

Tela principal do aplicativo. Exibe a biblioteca completa de jogos em formato grid estilo Steam, com capas reais buscadas automaticamente via Steam Store API e Twitch CDN. Cada card mostra nome do jogo, plataforma (Steam, Xbox, Rockstar, Other) com badge colorido, tempo de jogo e genero. Barra de busca no topo permite filtrar por nome. Sidebar lateral com navegacao para Jogos, Ferramentas, Treinamento e Configuracoes.

### 2. Detalhe do Jogo
**Arquivo:** `desktop/02-detalhe-jogo-sidebar.png`

Pagina de detalhes completa do jogo selecionado. Exibe capa em destaque, nome, botoes "Jogar" e "Remover", tempo de jogo, caminho do executavel. Secao de conquistas com barra de progresso e lista de todas as conquistas com nome, descricao e status (desbloqueado/bloqueado). Painel lateral direito com informacoes (ultima vez jogado, origem, categoria), sessoes recentes e requisitos do sistema.

### 3. Monitor de Hardware — Monitores
**Arquivo:** `desktop/03-monitor-hardware.png`

Secao de monitoramento de hardware dedicada a monitores. Exibe todos os displays conectados com detalhes: modelo, fabricante, resolucao nativa, taxa de atualizacao (refresh rate), tamanho fisico, conexao (DisplayPort, HDMI, Internal Panel), numero de serie e data de fabricacao. Sidebar de navegacao com Hardware, Monitores e Perifericos.

### 4. Monitor de Hardware — CPU/GPU/RAM
**Arquivo:** `desktop/04-hardware-cpu-gpu.png`

Dashboard completo de monitoramento em tempo real do sistema. Cards colapsaveis para cada componente:
- **Placa Mae:** Temperatura, VRM, ventoinhas RPM, voltagem
- **CPU:** Modelo (AMD Ryzen 7 5800X3D), uso %, clock, voltagem, potencia, temperaturas (Core/Package), grafico de uso em tempo real, ventoinhas (CPU Fan, AIO Pump)
- **GPU:** Modelo (NVIDIA GeForce GTX 1660 SUPER), uso %, clock, voltagem, potencia, temperatura, grafico de uso, ventoinhas
- **RAM:** Uso %, total/free/used com barra de progresso
- **Disco:** Espaco total/usado, velocidade de leitura/escrita
- **Rede:** Download/Upload em tempo real
- **FPS:** Deteccao automatica de jogo, estatisticas 1% low, 0.1% low, frame time

---

## Mobile — E.M.E Core Mobile (Android)

### 5. Tela de Conexao com Auto-Discovery
**Arquivo:** `mobile/05-tela-conexao.png`

Tela inicial do app mobile. Exibe o logo do E.M.E Core com titulo "Controle Remoto". Secao "PCs encontrados na rede" detecta automaticamente PCs rodando o EMECore desktop via UDP broadcast na rede local. Cards mostram nome do PC, IP e porta — basta tocar para conectar. Opcao de "Conexao manual (IP/Porta)" como fallback para redes sem broadcast.

### 6. Biblioteca de Jogos
**Arquivo:** `mobile/02-jogos.png`

Grid de jogos com capas reais em formato 2 colunas. Barra de busca no topo. Filtros por plataforma: Todos, Steam, Xbox, Outro — com estilo de pill/botao selecionavel. Cada card mostra capa, nome do jogo, badge da plataforma com cor identificadora e tempo de jogo. Navegacao por abas no rodape: Hardware e Jogos.

### 7. Monitor de Hardware
**Arquivo:** `mobile/03-hardware.png`

Dashboard de hardware em tempo real com cards organizados por componente:
- **CPU:** Modelo, uso % com barra de progresso azul, temperatura com barra laranja/verde, voltagem, potencia
- **GPU:** Modelo, uso %, temperatura, hotspot, voltagem, potencia, clock core, clock memoria
- **RAM:** Dados de uso com barra de progresso
- **FPS:** Status do overlay
- **Disco:** Velocidade de leitura/escrita
- **Rede:** Download/Upload

Dados atualizados a cada 1 segundo via WebSocket.

### 8. Detalhe do Jogo com Conquistas
**Arquivo:** `mobile/04-detalhe-jogo.png`

Tela de detalhes do jogo selecionado. Exibe capa em destaque no topo, nome do jogo, badge da plataforma, tempo de jogo, ultimo acesso. Botao "Jogar" grande e destacado para lancamento remoto. Secao de conquistas com contador (0/22) e lista de conquistas com icone, nome, descricao e status (cadeado para bloqueado). Cada conquista exibe imagem miniatura quando disponivel.

---

## Resumo Visual

| # | Tela | Plataforma | Arquivo |
|---|------|-----------|---------|
| 1 | Biblioteca de Jogos | Desktop | `desktop/01-biblioteca-jogos.png` |
| 2 | Detalhe do Jogo | Desktop | `desktop/02-detalhe-jogo-sidebar.png` |
| 3 | Monitor — Monitores | Desktop | `desktop/03-monitor-hardware.png` |
| 4 | Monitor — Hardware | Desktop | `desktop/04-hardware-cpu-gpu.png` |
| 5 | Conexao (Auto-Discovery) | Mobile | `mobile/05-tela-conexao.png` |
| 6 | Biblioteca de Jogos | Mobile | `mobile/02-jogos.png` |
| 7 | Monitor de Hardware | Mobile | `mobile/03-hardware.png` |
| 8 | Detalhe + Conquistas | Mobile | `mobile/04-detalhe-jogo.png` |
