# C. Brum Metalúrgica — Site

Site estático (HTML + CSS + JS puro, sem build, sem dependências). Basta subir estes arquivos em qualquer hospedagem.

## Estrutura

```
site/
├── index.html
├── css/style.css
├── js/script.js
└── img/            (fotos, logo, favicon)
```

## 1. Colocar no GitHub (pelo navegador, sem precisar instalar nada)

1. Acesse [github.com/new](https://github.com/new) e crie um repositório novo (ex.: `cbrum-site`). Pode deixar **público** ou **privado**, tanto faz para a Hostinger.
2. Na página do repositório recém-criado, clique em **"uploading an existing file"** (ou "Add file" → "Upload files").
3. Abra a pasta `site` no seu computador, selecione **todo o conteúdo de dentro dela** (o `index.html`, as pastas `css`, `js`, `img` — não a pasta `site` em si) e arraste para a página do GitHub.
   - Importante: o `index.html` precisa ficar na **raiz** do repositório, não dentro de uma subpasta `site/`.
4. Clique em **"Commit changes"**.

Pronto — o código está no GitHub.

## 2. Hospedar na Hostinger

### Opção A — Upload direto (mais simples, funciona em qualquer plano)

1. No GitHub, na página do repositório, clique em **"Code" → "Download ZIP"**.
2. Entre no **hPanel da Hostinger** → **Gerenciador de Arquivos** (File Manager).
3. Vá até a pasta `public_html` do seu domínio (apague o `default.php`/`index.html` de exemplo que já estiver lá, se houver).
4. Faça upload do ZIP baixado e use "Extrair" (Extract) dentro de `public_html`.
5. Confirme que `index.html` ficou direto dentro de `public_html` (não dentro de uma subpasta `site-main/`) — se precisar, mova os arquivos um nível acima e apague a subpasta vazia.
6. Acesse seu domínio — o site já deve estar no ar.

### Opção B — Deploy automático via Git (planos com integração Git da Hostinger)

Se seu plano Hostinger tiver a opção **"Git"** no hPanel:
1. hPanel → **Git** → cole a URL do repositório GitHub (ex.: `https://github.com/SEU_USUARIO/cbrum-site.git`).
2. Defina o diretório de destino como `public_html`.
3. Clique em **Deploy**. A cada novo commit no GitHub, você pode clicar em "Deploy" de novo para atualizar o site.

## Depois de publicar

- Confirme que o número de WhatsApp e os endereços em `index.html` estão corretos.
- Cole os códigos do **Meta Pixel** e do **Google Tag (GA4)** nos blocos comentados dentro de `<head>` em `index.html` (procure por "SEU_PIXEL_ID" e "SEU_ID_GA4").
- Teste o formulário/botões de WhatsApp e a navegação pelo celular real, não só no preview.
