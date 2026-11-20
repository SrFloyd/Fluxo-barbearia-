BARBOSA BARBEARIA — BUILD AJUSTADO AO SEU SUPABASE

Este pacote foi adaptado ao banco que já foi criado durante a configuração guiada.
Ele usa estas tabelas existentes:
- public.shops
- public.shop_members
- public.transactions

IMPORTANTE — NÃO EXECUTE UM ESQUEMA DIFERENTE
O arquivo supabase/schema.sql deste pacote é uma atualização de compatibilidade.
Ele não apaga tabelas nem movimentações. Ele:
1. adiciona a coluna services, se ainda não existir;
2. configura RLS e permissões;
3. permite leitura ao proprietário e ao sócio;
4. permite inserir, editar e excluir somente ao proprietário;
5. habilita Realtime para transactions, se necessário.

PASSO 1 — ATUALIZAR O SUPABASE
1. Abra o projeto existente no Supabase.
2. Entre em SQL Editor > New query.
3. Abra o arquivo supabase/schema.sql deste ZIP, copie todo o conteúdo e cole no editor.
4. Toque em Run. O esperado é “Success”.

PASSO 2 — CONFERIR OS VÍNCULOS
Você já executou o vínculo e a tela mostrou:
- maiconsoares2004@gmail.com — owner/proprietário
- oscomediawcl@gmail.com — partner/sócio

O aplicativo usa exatamente esses vínculos em public.shop_members. Não crie outra tabela de membros.

PASSO 3 — PUBLICAR OS ARQUIVOS
Publique juntos, em uma hospedagem HTTPS:
- index.html
- cloud-config.js
- manifest.webmanifest
- service-worker.js

O ZIP não é um APK. É um aplicativo web instalável (PWA). Abra o endereço HTTPS nos dois celulares.

PASSO 4 — ENTRAR
No celular do proprietário, entre com maiconsoares2004@gmail.com e a senha definida no Supabase.
No celular do sócio, entre com oscomediawcl@gmail.com e a senha própria.

A aplicação consulta public.shop_members para descobrir o papel do usuário e public.transactions para carregar o caixa compartilhado.

SEGURANÇA
- O navegador recebe somente a URL e a chave publishable/anon.
- Nunca coloque chave secret/service_role no arquivo cloud-config.js.
- As regras RLS no banco são a proteção real; esconder botões na interface não substitui essas regras.
- A interface oculta as telas de entrada/despesa e os controles de backup/restauração para o sócio. As funções de escrita também verificam o papel antes de enviar alterações.
- Não compartilhe senhas por mensagem.

OBSERVAÇÕES
- O aplicativo foi adaptado para a estrutura SQL já criada no projeto do usuário (shops/shop_members/transactions).
- Os lançamentos são compartilhados entre as contas vinculadas à mesma shop_id.
- O backup JSON continua disponível para o proprietário.
- A sincronização em tempo real depende de a publicação supabase_realtime incluir public.transactions; o SQL acima tenta habilitá-la sem duplicar a tabela.
