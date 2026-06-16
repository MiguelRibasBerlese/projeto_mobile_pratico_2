# CineTrack — Diário de Filmes

Aplicativo mobile/web de diário de filmes desenvolvido com Flutter e Dart.
**Parte 2:** Firebase (Auth + Cloud Firestore), consumo de API REST (OMDb) e
design system dark cinema (Material 3 + Google Fonts).

## Disciplina
AC622 — Programação Mobile II
UNAERP — Campus Ribeirão Preto
Professor: Prof. Dr. Samuel Oliva

## Integrantes
- Miguel Ribas Berlese — 839938
- Enzo Shimada Daun — 840552

## Modo seguro x Modo Firebase

O app roda em dois modos, controlados por `lib/firebase_config.dart`:

| `kFirebaseEnabled` | Comportamento |
|--------------------|---------------|
| `false` (padrão)   | **Modo seguro** — dados mockados em memória. Roda sem nenhuma configuração de Firebase. |
| `true`             | **Modo Firebase** — autenticação real, persistência no Firestore, listagens em tempo real (StreamBuilder) e perfil do usuário. |

> O modo seguro existe porque `firebase_options.dart` só é gerado por
> `flutterfire configure` (que exige credenciais Google + um projeto Firebase).
> Assim o app **compila e roda** mesmo antes do Firebase ser configurado.

## Como executar (modo seguro)
1. Instale o Flutter SDK (https://flutter.dev)
2. `flutter pub get`
3. `flutter run -d chrome`

## Habilitar o Firebase (modo Firebase)

1. Acesse https://console.firebase.google.com e crie o projeto.
2. Ative **Authentication → Email/Senha**.
3. Ative **Cloud Firestore → Production mode**.
4. Em **Firestore → Rules**, cole o conteúdo de [`firestore.rules`](firestore.rules) e publique.
5. No terminal, na raiz do projeto:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=SEU_PROJETO   # gera lib/firebase_options.dart
   ```
6. Em `lib/main.dart`: descomente os imports de `firebase_core`/`firebase_options`
   e a chamada a `Firebase.initializeApp(...)`.
7. Em `lib/firebase_config.dart`: mude `kFirebaseEnabled` para `true`.
8. Em `lib/utils/constants.dart`: confirme que `kOmdbApiKey` está preenchida
   com uma chave válida de https://omdbapi.com (gratuita).
9. `flutter run -d chrome`

> As consultas de `streamFilmes`/`pesquisarFilmes` usam `where(uid) + orderBy/range`.
> Na primeira execução o Firestore pode pedir a criação de um **índice composto** —
> basta seguir o link exibido no console de erro.

## Requisitos atendidos (Parte 2)

- **RF001** — Login + recuperação de senha via Firebase Auth com tradução de erros.
- **RF002** — Cadastro via Firebase + 3 campos adicionais (nome, telefone, gênero
  favorito) na coleção `usuarios` + validação robusta de senha (8+ caracteres,
  maiúscula, minúscula, número, especial).
- **RF003** — Inserção em 4 coleções: `usuarios`, `filmes`, `avaliacoes`, `listas`
  (cada uma com 5+ campos) + SnackBar de confirmação.
- **RF004** — Atualização em `filmes` (status), `avaliacoes` (nota/comentário),
  `listas` (nome/descrição) e `usuarios` (perfil).
- **RF005** — `StreamBuilder + ListView` em tempo real para `filmes`,
  `avaliacoes` e `listas`, todas filtradas por `uid`.
- **RF006** — Tela **exclusiva** de pesquisa, busca case-insensitive
  (`tituloLower`) e ordenação por 5 critérios.
- **RF007** — API OMDb consumida com `http`, model `OmdbFilme.fromJson`,
  `OmdbService`, `FutureBuilder + ListView`.

## Estrutura

```
lib/
  firebase_config.dart          # flag kFirebaseEnabled
  app/auth_gate.dart            # gate: modo seguro x modo Firebase
  models/                       # OmdbFilme, FilmeModel, AvaliacaoModel, ListaModel, UsuarioModel
  services/                     # auth, filme, avaliacao, lista, usuario (Firebase) + omdb (HTTP)
  screens/
    auth/                       # login, cadastro, recuperar senha
    home/                       # tela principal (BottomNav: Filmes/Avaliações/Listas)
    filmes/                     # buscar (OMDb), pesquisa exclusiva, detalhes
    avaliacoes/                 # listagem + edição de avaliações
    listas/                     # listas personalizadas
    perfil/                     # edição de perfil
    sobre/                      # sobre o projeto
  widgets/                      # star_rating, filme_card, empty_state, loading_button
firestore.rules                 # regras de segurança por uid
```

## Tecnologias
Flutter · Dart · Firebase Auth · Cloud Firestore · API OMDb (REST) ·
Material Design 3 · Google Fonts
