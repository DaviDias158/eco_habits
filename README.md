# EcoHabits - Gestão de Hábitos Sustentáveis

O **EcoHabits** é uma plataforma web interativa desenvolvida para engajar comunidades na adoção de hábitos sustentáveis. Através dela, usuários podem cadastrar rotinas ecológicas, registrar suas ações diárias, acumular pontos no perfil e acompanhar o impacto global em um feed comunitário atualizado em tempo real.

Este projeto foi construído utilizando o ecossistema **Elixir** e o framework **Phoenix com LiveView**, aplicando conceitos avançados de programação funcional, imutabilidade e concorrência baseada no Modelo de Atores.

---

## Como Iniciar a Aplicação

Para rodar este projeto localmente na sua máquina, certifique-se de ter o **Elixir**, o **Erlang** e o banco de dados **PostgreSQL** instalados e ativos.

### 1. Baixar as dependências do ecossistema
Abra o terminal na pasta raiz do projeto e baixe os pacotes necessários:

```bash
mix deps.get

```


### 2. Configurar e migrar o banco de dados

Crie o banco local e execute as migrações (que estruturam as tabelas e as travas de segurança do PostgreSQL):

```bash
mix ecto.setup

```

### 3. Subir o servidor do Phoenix

Inicie o servidor local para colocar a aplicação web no ar:

```bash
mix phx.server

```

Agora, abra o seu navegador e acesse as rotas do sistema:

* **Página Inicial / Entrada:** `http://localhost:4000`
* **Cadastro de Usuário (Módulo A):** `http://localhost:4000/users/register`
* **Login no Sistema (Módulo A):** `http://localhost:4000/users/log-in`
* **Página de Perfil e Bio (Módulo A):** `http://localhost:4000/users/profile`
* **Gestão e Filtro de Hábitos (Módulo B):** `http://localhost:4000/habits`
* **Super Tela do Tracker e Feed (Módulo C):** `http://localhost:4000/tracker`

---

## Guia de Uso Completo (O que dá para fazer no sistema?)

Abaixo está o passo a passo de todas as interações e operações permitidas dentro do EcoHabits, cobrindo o ciclo completo de uso.

### 1. Autenticação e Gestão de Perfil

* **Criar uma conta:** Acesse a página de cadastro, preencha seu **Nome**, **E-mail** e uma **Senha** segura. O sistema valida campos obrigatórios e impede e-mails duplicados.
* **Acessar/Sair do sistema:** Faça login para obter uma sessão persistente segura. Você pode desconectar a qualquer momento clicando em "Log out".
* **Editar seu Perfil:** Na página de perfil, você pode visualizar seu nome, conferir sua pontuação acumulada histórica e atualizar sua **Bio personalizada**. Clique em salvar para atualizar as informações instantaneamente.

### 2. Gestão de Hábitos Sustentáveis

O gerenciamento de hábitos permite criar as ações ecológicas que darão pontos aos usuários.

* **Cadastrar um Hábito:** Vá para a área de hábitos e clique em criar. Insira o **Nome**, **Descrição**, a **Pontuação** atribuída (ex: `10`, `20`) e selecione uma das categorias oficiais: `Alimentação`, `Transporte`, `Energia`, `Água` ou `Resíduos`.
* **Listar e Filtrar Hábitos:** Na tela principal de hábitos, visualize todos os cadastros do sistema. Use o menu de filtros para selecionar uma categoria específica (ex: filtrar apenas hábitos de `Água`) para limpar a listagem.
* **Editar um Hábito:** Se você foi o criador do hábito, clique no botão de edição para modificar o nome, a pontuação ou a categoria caso tenha digitado algo errado.
* **Excluir um Hábito:** Caso um hábito criado por você não faça mais sentido, clique em "Excluir" para removê-lo definitivamente do sistema.

### 3. Registro (Check-in) e Acompanhamento Comunitário

A central de engajamento unifica o monitoramento pessoal e a interação da comunidade.

* **Registrar a prática de um Hábito (Check-in):** Na tela do Tracker (`/tracker`), clique no botão do hábito que você praticou hoje (ex: `+15 Pts`).
* *O que acontece:* O sistema registra a ação, computa os pontos imediatamente no seu perfil e atualiza seu histórico.


* **A trava de segurança diária:** Se você tentar clicar no botão do **mesmo hábito outra vez no mesmo dia**, o sistema barretará a ação exibindo um alerta vermelho informando que o check-in diário para aquele hábito já foi realizado.
* **Visualizar o Dashboard:** Na coluna central, acompanhe o seu histórico pessoal detalhado com o nome de cada hábito praticado e o dia/hora em que a ação foi registrada.
* **Acompanhar o Feed em Tempo Real:** A coluna da direita exibe um feed dinâmico com os check-ins mais recentes de todos os usuários da comunidade. Quando qualquer usuário faz um check-in, um card com o nome dele e o hábito praticado surge instantaneamente no topo do feed de todo mundo que estiver com a página aberta, sem necessidade de atualizar o navegador (F5).

---

## Conceitos Funcionais Aplicados

Para fins acadêmicos, a arquitetura deste projeto destaca-se pelos seguintes pilares da programação funcional:

* **Modelo de Atores e Concorrência:** O feed da comunidade utiliza o `Phoenix.PubSub` rodando em memória na BEAM, distribuindo mensagens assíncronas de forma isolada entre múltiplos processos de LiveViews ativos.
* **Imutabilidade e Manipulação de Fluxos:** A renderização e inserção de dados em tempo real na interface utiliza o mecanismo de `Streams` do Phoenix, otimizando o consumo de memória ao evitar a mutação ou o recarregamento de grandes coleções de dados estruturados.
* **Garantia de Estado via Changesets:** Toda entrada de dados e tratamento de colisões colhidas do banco relacional são tratadas como transições de estado puras através de estruturas imutáveis do `Ecto.Changeset`.
