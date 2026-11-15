# DRAW TO SURVIVE

Um jogo mobile 2D de puzzles físicos no qual o jogador desenha linhas para proteger personagens, criar caminhos e superar obstáculos.

## Estado do projeto

**Fase atual: 1 — Fundação do projeto**

Esta fase estabelece o projeto Godot, a interface inicial e a compilação Android automatizada. A mecânica principal de desenho será desenvolvida na Fase 2.

## Tecnologias

- Godot Engine 4.7.2 Stable
- GDScript
- Godot Physics 2D
- Android (APK)
- GitHub Actions para integração contínua e exportação

## Abrir o projeto

1. Instale o Godot **4.7.2 Standard**.
2. Clone este repositório.
3. Abra o ficheiro `project.godot` no Godot.
4. Execute o projeto com **F6/F7** ou pelo botão Executar.

## Compilar APK localmente

Configure o Java JDK 17 e o Android SDK nas definições do editor Godot. Instale os templates de exportação correspondentes à versão 4.7.2 e execute:

```bash
mkdir -p build
godot --headless --path . --export-debug "Android" build/DrawToSurvive-debug.apk
```

## Compilação automática

Cada push para `main` e cada pull request executam o workflow **Android Build**. Quando a exportação for concluída, o APK de debug fica disponível nos artefactos da execução do GitHub Actions.

O workflow também permite execução manual através de **Actions → Android Build → Run workflow**.

## Estrutura

```text
.
├── .github/workflows/android.yml
├── assets/
│   └── icon.svg
├── scenes/
│   └── menus/
│       ├── main_menu.tscn
│       └── info_screen.tscn
├── scripts/
│   └── menus/
│       ├── main_menu.gd
│       └── info_screen.gd
├── .gitignore
├── export_presets.cfg
└── project.godot
```

## Identidade do Android

- Nome: Draw to Survive
- Identificador: `com.huzeifaumar.drawtosurvive`
- Orientação: retrato
- Renderizador: Compatibility (OpenGL), para maior compatibilidade com dispositivos Android.

## Próximas fases

- **Fase 2:** desenho com o dedo, física das linhas, colisões e ciclo de jogo.
- **Fase 3:** campanha inicial, progressão, recompensas e gravação local.
- **Fase 4:** desafios inteligentes, conteúdo procedural e monetização.
- **Fase 5:** otimização, testes finais e preparação para publicação.

## Estado da versão

Versão de fundação: **0.1.0**. Esta versão contém o menu inicial e o ecrã informativo; ainda não contém a mecânica principal de jogo.
