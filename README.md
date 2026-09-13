# Calculadora Flutter

Calculadora simples feita em Flutter, com as quatro operações básicas e um histórico dos cálculos da sessão.

O projeto tem dois objetivos:

1. **Aprender a estrutura de um app Flutter**: widgets, estado, navegação, enums e organização de pastas.
2. **Gerar o app para iOS sem ter um Mac**, usando GitHub Actions (máquina macOS na nuvem).

---

## Funcionalidades

- Soma, subtração, multiplicação e divisão
- Multiplicação e divisão são resolvidas antes de soma e subtração
- Números decimais com vírgula (`,`)
- Botões **C** (limpar) e **⌫** (apagar o último caractere)
- Trocar o operador: apertar `+` e depois `-` substitui o último operador
- Tela de **histórico** com os cálculos feitos (fica só na memória, some ao fechar o app)

---

## Estrutura do projeto

```
lib/
├── main.dart                     # Ponto de entrada: MaterialApp, tema e tela inicial
├── enum/
│   └── operation_type.dart       # Enum das operações com o símbolo de cada uma
├── pages/
│   ├── calculadora_page.dart     # Tela principal: display, teclado e lógica do cálculo
│   └── historic_page.dart        # Tela com a lista de cálculos feitos
└── widgets/
    └── button_widgets.dart       # Botão reutilizável do teclado
.github/
└── workflows/
    ├── dart.yml                  # Pipeline que gera o .ipa do iOS em um Mac da nuvem
    └── android-apk.yml           # Pipeline que gera o .apk do Android em um Linux da nuvem
```

### O que cada arquivo ensina

| Arquivo | Conceitos |
|---|---|
| `main.dart` | `runApp`, `StatelessWidget`, `MaterialApp`, `ThemeData` com `ColorScheme.fromSeed` e Material 3 |
| `operation_type.dart` | **Enhanced enum**: um enum com campo (`symbol`) e construtor `const` |
| `calculadora_page.dart` | `StatefulWidget` + `State`, `initState`, `setState`, `Scaffold`/`AppBar`, layout com `Column`, `Row` e `Expanded`, navegação com `Navigator.push` e `MaterialPageRoute`, `RegExp` |
| `historic_page.dart` | Passar dados entre telas pelo construtor, `ListView.builder`, renderização condicional (`? :`), `Card` e `ListTile` |
| `button_widgets.dart` | Criar um widget próprio, parâmetros obrigatórios e opcionais (`required`, `Color?`, `??`), callbacks com `VoidCallback` |

### Recursos recentes do Dart usados no código

- **Dot shorthands** (Dart 3.10+): `alignment: .bottomRight` e `colorScheme: .fromSeed(...)`. O tipo fica implícito, então não precisa escrever `Alignment.` ou `ColorScheme.`.
- **Construtor com `new`**: `const new({super.key});` em `CalculadoraPage` é o mesmo que `const CalculadoraPage({super.key});`.

---

## Como o cálculo funciona

Tudo fica em `calculadora_page.dart`. O display é uma `String` (ex.: `2+3X4`), e o botão `=` a resolve em etapas:

1. **`calculate()`** troca `,` por `.` para o Dart conseguir converter os números.
2. **`parseNumber()`** usa uma regex para separar os números: `[2, 3, 4]`.
3. **`getOperators()`** pega os símbolos e converte para o enum: `[addition, multiplication]`.
4. **`resolvePriorityOperations()`** resolve `X` e `÷` primeiro, juntando os números da lista: `[2, 12]` e `[addition]`.
5. **`resolveAdditionAndSubtraction()`** resolve o que sobrou, da esquerda para a direita: `14`.
6. O resultado aparece no display e a expressão entra no histórico.

---

## Como rodar

Pré-requisito: [Flutter SDK](https://docs.flutter.dev/get-started/install) (projeto criado com Flutter 3.47 / Dart 3.13).

```bash
flutter pub get
flutter run            # escolhe o dispositivo (Android, Windows, Chrome...)
flutter analyze        # análise estática
flutter test           # testes
```

---

## Build para iOS sem Mac

O Flutter só compila para iOS em macOS, porque precisa do Xcode. Sem um Mac, a saída é usar um **Mac na nuvem**. Este projeto usa o **GitHub Actions** para isso.

### Como o workflow funciona (`.github/workflows/dart.yml`)

1. Liga uma máquina `macos-latest` no GitHub.
2. Instala o Flutter (canal stable) e roda `flutter pub get`.
3. Roda `flutter build ios --release --no-codesign`, que compila **sem assinatura** da Apple.
4. Coloca o `Runner.app` numa pasta `Payload` e compacta como `FlutterIpaExport.ipa`.
5. Publica o `.ipa` na aba **Releases** do repositório, com a tag `v1.0`.

### Como disparar

O workflow é manual (`workflow_dispatch`):

1. No GitHub, abra a aba **Actions**.
2. Escolha **iOS-ipa-build** e clique em **Run workflow**.
3. Quando terminar, baixe o `FlutterIpaExport.ipa` em **Releases**.

> Repositórios públicos têm minutos de macOS gratuitos no GitHub Actions. Em repositórios privados, os minutos de macOS gastam a cota bem mais rápido que os de Linux.

### Como instalar o .ipa num iPhone

O `.ipa` gerado **não é assinado**, então o iPhone não instala direto. As opções são:

| Opção | Custo | Observações |
|---|---|---|
| **Sideloadly** ou **AltStore** (no Windows) | Grátis, com Apple ID comum | O app vale por **7 dias** e depois precisa reinstalar. Limite de 3 apps ao mesmo tempo |
| **TestFlight / App Store** | Apple Developer Program (US$ 99/ano) | Precisa de certificado e provisioning profile no workflow e de um bundle id próprio (hoje é `com.example.calculadora`) |
| **Codemagic** | Plano gratuito com minutos mensais em Mac | Serviço de CI focado em Flutter. Ajuda a gerenciar a assinatura da Apple |

### Melhorias sugeridas para o workflow

- Trocar `actions/checkout@v3` pela versão mais recente.
- Tirar `architecture: x64`: os runners `macos-latest` usam Apple Silicon (arm64).
- Adicionar `permissions: contents: write` no job, senão o `GITHUB_TOKEN` pode não ter permissão para criar a release.
- Tirar o passo `pod repo update`, que é lento e dispensável num projeto sem plugins nativos.
- Usar tags dinâmicas (ex.: `v1.0.${{ github.run_number }}`) para não sobrescrever sempre a mesma release.

---

## Build para Android

Diferente do iOS, o Android **pode ser compilado no Windows**. Só precisa do Android SDK (vem com o Android Studio) e do JDK 17.

### No próprio computador

```bash
flutter build apk --release                 # APK único, funciona em qualquer celular
flutter build apk --release --split-per-abi # um APK menor por arquitetura (arm64, armv7, x86_64)
flutter build appbundle --release           # .aab, formato exigido pela Play Store
```

O arquivo sai em `build/app/outputs/flutter-apk/app-release.apk`.

### Pelo GitHub Actions (`.github/workflows/android-apk.yml`)

1. Liga uma máquina `ubuntu-latest`, que é mais barata e rápida que a de macOS.
2. Instala o Java 17 e o Flutter (canal stable, com cache).
3. Roda `flutter build apk --release` e renomeia a saída para `FlutterApkExport.apk`.
4. Publica o APK de dois jeitos:
   - como **artifact** na página da execução
   - na aba **Releases**, na mesma tag `v1.0` do `.ipa`

Para disparar: aba **Actions** → **Android-apk-build** → **Run workflow**.

### Como instalar o .apk

Passe o arquivo para o celular e abra. O Android pede para liberar a **instalação de fontes desconhecidas**.

### Assinatura

Hoje o build de release é assinado com a **chave de debug** (veja `android/app/build.gradle.kts`). Isso basta para instalar no celular, mas **não é aceito na Play Store**. Para publicar lá:

1. Criar uma chave própria com `keytool` e trocar o `applicationId` (hoje é `com.example.calculadora`).
2. Configurar `signingConfigs` com a chave no `build.gradle.kts`.
3. No workflow, guardar a chave e as senhas em **GitHub Secrets** (a chave em Base64) e gerar um `.aab`.

---

## Problemas conhecidos e próximos passos

Pontos encontrados na análise do código, bons para praticar:

- **Operador no final trava o cálculo**: `5+` seguido de `=` gera um `RangeError`, porque sobra um operador sem número. Dá para validar a expressão antes de calcular.
- **Resultado negativo quebra o próximo cálculo**: depois de um resultado `-1,0`, digitar `+2` e `=` gera erro. A regex ignora o sinal negativo e o `-` do começo é tratado como operador.
- **Várias vírgulas no mesmo número** (`1,2,3`) são aceitas e geram números errados.
- **Divisão por zero** mostra `Infinity`.
- **Resultado sempre com casa decimal** (`5,0`), porque `double.toString()` sempre inclui a parte decimal. Dá para mostrar como inteiro quando não houver decimais.
- **Histórico com `.` em vez de `,`**: a expressão é salva depois da troca de `,` por `.`.
- **Código repetido no teclado**: os botões podem ser gerados a partir de uma lista, o que deixa o `build` bem menor.
- **Separar lógica da interface**: mover o cálculo para uma classe própria (ex.: `lib/services/calculator.dart`) facilita escrever testes unitários.
- **`HistoricPage` pode ser `StatelessWidget`**, porque não guarda estado próprio.
- **Salvar o histórico** entre sessões com `shared_preferences`.

---

## Referências

- [Jonathan Rebouças](https://youtu.be/wMK09GI-gV0?si=A6vIeuvR_Po7opaF)
- [Programming With FlexZ](https://youtu.be/mQMy12Sk0xM?si=yDnTHLivj0v5bSLW)
- [Documentação do Flutter](https://docs.flutter.dev/)
- [Enhanced enums (Dart)](https://dart.dev/language/enums#declaring-enhanced-enums)
- [Dot shorthands (Dart)](https://dart.dev/language/dot-shorthands)
- [Build and release an iOS app (Flutter)](https://docs.flutter.dev/deployment/ios)
- [Build and release an Android app (Flutter)](https://docs.flutter.dev/deployment/android)
- [GitHub Actions](https://docs.github.com/actions)
