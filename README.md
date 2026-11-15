# DRAW TO SURVIVE

Jogo mobile 2D de puzzles físicos feito com Godot 4. O jogador desenha estruturas com o dedo para guiar uma bola até ao portal e evitar perigos.

## Estado do projeto

**Fase atual: 2 — Mecânica principal**

A fundação e a exportação Android estão configuradas. A Fase 2 adiciona um primeiro nível jogável com desenho tátil, colisões físicas, simulação, objetivo, perigo, vitória, derrota e reinício.

## Tecnologias

- Godot Engine 4.7.2 Stable
- GDScript e Godot Physics 2D
- Android (APK)
- GitHub Actions para validação e exportação automática

## Jogar

1. Abre o menu e toca em **JOGAR**.
2. Desenha uma linha contínua na área de jogo. A linha transforma-se numa estrutura com colisão física.
3. Toca em **SOLTAR BOLA** para iniciar a simulação.
4. Guia a bola até ao portal verde, evitando os espinhos vermelhos.
5. Usa **REINICIAR** para experimentar outra solução ou **MENU** para voltar.

No computador, também podes desenhar com o botão esquerdo do rato.

## Abrir o projeto

1. Instala o Godot **4.7.2 Standard**.
2. Clona este repositório.
3. Abre `project.godot`.
4. Executa o projeto pelo botão Run.

## Compilar APK localmente

Configura o Java JDK 17 e o Android SDK no Godot, instala os templates de exportação da mesma versão e executa:

```bash
mkdir -p build
godot --headless --path . --export-debug "Android" build/DrawToSurvive-debug.apk
```

## Compilação automática

Cada push para `main` e cada pull request executam o workflow **Android Build**. O APK de debug é publicado como artefacto da execução do GitHub Actions.

## Estrutura

```text
.
├── .github/workflows/android.yml
├── assets/icon.svg
├── scenes/
│   ├── menus/
│   │   ├── main_menu.tscn
│   │   └── info_screen.tscn
│   └── gameplay/game.tscn
├── scripts/
│   ├── menus/
│   │   ├── main_menu.gd
│   │   └── info_screen.gd
│   └── gameplay/game.gd
├── export_presets.cfg
└── project.godot
```

## Identidade Android

- Nome: Draw to Survive
- Package: `com.huzeifaumar.drawtosurvive`
- Orientação: retrato
- Renderizador: Compatibility (OpenGL)

## Próximas fases

- **Fase 3:** campanha inicial, progressão, recompensas e gravação local.
- **Fase 4:** desafios inteligentes, conteúdo procedural e monetização.
- **Fase 5:** otimização, testes finais e preparação para publicação.

Versão atual: **0.2.0**.
