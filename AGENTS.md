# AGENTS.md

# E.M.E Core Mobile — Diretrizes de Desenvolvimento para IA

Este documento define as regras obrigatórias para todos os agentes de IA trabalhando no projeto EMECoreMobile.

Essas regras devem ser sempre seguidas, a menos que o usuário solicite explicitamente o contrário.

---

# 1. Visão Geral do Projeto

**Nome do Projeto:** E.M.E Core Mobile

**Propósito:** App Flutter para Android que funciona como controle remoto do E.M.E Core (desktop Windows). Permite monitorar hardware, gerenciar biblioteca de jogos, visualizar conquistas e lançar jogos remotamente.

**Relação:** Complementa o desktop [EMECore](https://github.com/Eriklebson/EMECore) — não substitui.

---

# 2. Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| Framework | Flutter 3.44+ |
| Linguagem | Dart 3.12+ |
| WebSocket | `web_socket_channel` v3.0.0 |
| Discovery | `dart:io` RawDatagramSocket (UDP) |
| State | Streams + StreamController |
| Protocolo | JSON |
| Plataforma | Android (SDK 36) |

---

# 3. Arquitetura

```
EMECoreMobile/lib/
├── main.dart                    # Entry point, tema, rotas
├── models/                      # Modelos de dados
│   ├── hardware_stats.dart      # CPU/GPU/RAM/FPS/Disco/Rede/MB
│   ├── game.dart                # Modelo de jogo
│   └── achievement.dart         # Conquistas com progresso
├── services/                    # Logica de negocio
│   ├── websocket_service.dart   # Cliente WebSocket + protocolo
│   └── discovery_service.dart   # Auto-discovery via UDP
└── pages/                       # Interface
    ├── connection_page.dart     # Tela de conexao
    ├── home_page.dart           # Navegacao principal
    ├── hardware_page.dart       # Monitor em tempo real
    ├── games_page.dart          # Biblioteca de jogos
    └── game_detail_page.dart    # Detalhe + conquistas
```

**Princípios:**
- Separação de responsabilidades (models / services / pages)
- Serviços contêm lógica de negócio
- Pages são apenas UI
- Comunicação via Streams (reactive)

---

# 4. Versionamento

O projeto segue **Semantic Versioning (SemVer)**.

## Formato

`MAJOR.MINOR.PATCH+BUILD`

- **MAJOR** — Breaking changes, redesign completo
- **MINOR** — Novas features, novos módulos
- **PATCH** — Correções de bug, melhorias pequenas
- **BUILD** — Número incrementado a cada build (versionCode Android)

## Arquivos a Atualizar

Quando a versão mudar, a IA DEVE atualizar TODOS estes arquivos:

| Arquivo | Campo | Formato | Exemplo |
|---------|-------|---------|---------|
| `pubspec.yaml` | `version` | `X.Y.Z+N` | `1.1.0+2` |
| `README.md` | Tabela de versões | `1.1.0` | Adicionar linha |
| `CHANGELOG_AI.md` | Nova entrada | Markdown | Documentar mudança |

## Regras de Incremento

**PATCH** (incrementar 3º dígito):
- Correções de bug
- Correções de performance
- Pequenas melhorias internas

Exemplo: `1.0.0+1` → `1.0.1+2`

---

**MINOR** (incrementar 2º dígito, resetar 3º para 0):
- Novas features
- Novos módulos
- Novas integrações

Exemplo: `1.0.1+2` → `1.1.0+3`

---

**MAJOR** (incrementar 1º dígito, resetar outros para 0):
- Breaking changes
- Redesign completo
- Mudanças grandes de arquitetura

Exemplo: `1.9.0+15` → `2.0.0+16`

---

# 5. Documentação

Antes de implementar QUALQUER feature, a IA DEVE:

1. Ler a documentação existente
2. Entender a arquitetura atual
3. Preservar a arquitetura existente
4. Atualizar a documentação após finalizar

Documentação é parte do código. Nunca deixar documentação desatualizada.

---

# 6. Report de Desenvolvimento

Toda tarefa completa deve gerar um report de desenvolvimento em Markdown.

**Localização:** `CHANGELOG_AI.md`

O report deve conter:
- Data
- Arquivos modificados
- Resumo
- Explicação detalhada
- Motivo da mudança
- Possíveis impactos

Escrito em linguagem clara, compreensível pelo dono do projeto.

---

# 7. README

Sempre que uma feature estiver completa o suficiente para commit, o `README.md` deve ser atualizado.

O README deve sempre refletir o status atual do projeto:
- Novas features
- Novos screenshots (se necessário)
- Mudanças de instalação
- Mudanças de uso

---

# 8. Tema Visual

Manter a identidade visual atual.

**Tema:** Dark theme inspirado no Steam.

| Elemento | Cor |
|----------|-----|
| Background | `#161719` |
| Surface/Cards | `#1B2838` |
| Accent | `#66C0F4` |
| Border | `#2A475E` |
| Text Muted | `#8F98A0` |
| Error | `#D94040` |

Não redesenhar a interface a menos que solicitado explicitamente.

---

# 9. Performance

Performance é obrigatória.

**Preferir:**
- Async/Await
- Programação event-driven (Streams)
- Lazy loading
- Cancelamento de timers/stream subscriptions

**Evitar:**
- Polling infinito
- Busy loops
- Alocações desnecessárias
- Widgets que reconstruído sem necessidade

O app deve consumir o mínimo possível de RAM e bateria.

---

# 10. Compatibilidade

Manter preparado para:
- iOS (já existe scaffold)
- Desktop (Linux/macOS/Windows via Flutter)
- Notificações push
- Widgets nativos

Mesmo que não implementado agora, não bloquear implementações futuras.

---

# 11. Git Workflow

A IA NUNCA deve commitar, enviar, merge, rebase, tag ou modificar o histórico Git sem autorização explícita do usuário.

**Permitido sem perguntar:**
- Ler status do Git
- Ler histórico de commits
- Comparar branches
- Mostrar diffs

**Não permitido sem autorização:**
- `git add`
- `git commit`
- `git push`
- `git pull`
- `git merge`
- `git rebase`
- `git reset`
- `git tag`
- `git stash`
- Qualquer operação destrutiva do Git

Antes de qualquer commit ou push, a IA deve:
1. Confirmar que a implementação está completa
2. Confirmar que o projeto compila
3. Confirmar que o usuário testou
4. Aguardar aprovação explícita

---

# 12. Validação Antes da Conclusão

Uma tarefa NUNCA deve ser considerada completa apenas porque compila.

Antes de considerar implementação completa:
- Build do projeto bem-sucedido
- App abre sem crashes
- Funcionalidade modificada validada
- Confirmação do usuário

A implementação só é considerada completa após aprovação explícita.

---

# 13. Workflow de Build

## Build Debug
```bash
flutter pub get
flutter build apk --debug
```

## Deploy via USB
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell monkey -p com.eme.emecore_mobile -c android.intent.category.LAUNCHER 1
```

## Limpeza
```bash
flutter clean
flutter pub get
```

---

# 14. Diagnóstico

Quando o usuário relatar um bug:

1. **Estudar o código primeiro** — Ler arquivos relevantes
2. **Coletar evidências** — `flutter run --verbose`, `adb logcat`, `flutter analyze`
3. **Formular hipótese** — Explicar a causa raiz ANTES de sugerir mudanças
4. **Validar** — Confirmar o problema com logs ou análise
5. **Implementar** — Fazer a menor mudança possível

Proibido: mudanças baseadas em "achismo", tentativa e erro.

---

# 15. Controle de Escopo

Implementar apenas o que foi solicitado.

Não criar features adicionais sem aprovação do usuário.

Se uma melhoria for identificada:
1. Explicar a sugestão
2. Aguardar aprovação
3. Só implementar após aprovação

---

# 16. Idioma

Toda documentação, commits e textos da UI devem estar em **Português (PT-BR)**.

A única exceção é o código (nomes de variáveis, classes, etc.), que deve seguir convenções Dart em inglês.

---

# 17. Comunicação com Desktop

O app se comunica com o E.M.E Core desktop via WebSocket (porta 8181) e UDP beacon (porta 8182).

## Protocolo WebSocket

### Desktop → Mobile
| Tipo | Descrição |
|------|-----------|
| `welcome` | Boas-vindas após conexão |
| `hardware_stats` | Stats de hardware (1s) |
| `game_list` | Lista de jogos |
| `achievements` | Conquistas |
| `game_launched` | Confirmação de launch |
| `pong` | Resposta ao ping |

### Mobile → Desktop
| Tipo | Parâmetros | Descrição |
|------|-----------|-----------|
| `get_hardware` | — | Solicita stats |
| `get_games` | — | Solicita jogos |
| `launch_game` | `gameId` | Lança jogo |
| `get_achievements` | `gameId` | Solicita conquistas |
| `ping` | — | Keep-alive (30s) |

## UDP Beacon (porta 8182)

```json
{
  "app": "EMECore",
  "ip": "192.168.0.102",
  "port": 8181,
  "name": "NomeDoPC"
}
```

---

# 18. Autoridade da IA

Este AGENTS.md é a fonte de verdade de maior prioridade para este projeto.

Sempre consultar este documento antes de tomar decisões.

Se documentação e código conflitarem, atualizar a documentação se o código representar o comportamento desejado, caso contrário preservar a arquitetura documentada e perguntar ao usuário.

---

**Autor:** Eriklebson — [GitHub](https://github.com/Eriklebson)

**Desktop:** [EMECore](https://github.com/Eriklebson/EMECore)
