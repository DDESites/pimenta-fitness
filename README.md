# Academia Pimenta Fitness — Site institucional

Site institucional da **Academia Pimenta Fitness**, em Águas Lindas de Goiás/GO.
Projeto estático (HTML, CSS e JavaScript puros), sem build, sem dependências e sem
framework. Todos os caminhos são relativos, então o site funciona igual no GitHub Pages,
em um servidor próprio ou aberto direto do disco.

## Estrutura do site

| Página              | Arquivo             | Conteúdo                                                      |
| ------------------- | ------------------- | ------------------------------------------------------------- |
| Início              | `index.html`        | Hero, diferenciais, modalidades, planos, depoimentos, contato |
| A academia          | `academia.html`     | Estrutura, equipe, galeria de fotos, comodidades              |
| Modalidades         | `modalidades.html`  | Musculação, aulas coletivas, pilates e funcional              |
| Planos              | `planos.html`       | Planos, Wellhub, condições de matrícula e FAQ                 |
| Contato             | `contato.html`      | WhatsApp, formulário, mapa e horários                         |
| Política de privacidade | `privacidade.html` | Tratamento dos dados enviados pelo formulário (LGPD)      |

## Estrutura de pastas

```
pimenta-fitness/
├── index.html
├── academia.html
├── modalidades.html
├── planos.html
├── contato.html
├── privacidade.html
├── css/
│   └── styles.css      # Design system completo (variáveis, layout, responsivo)
├── js/
│   └── main.js         # Menu mobile, animações de scroll, lightbox, validação
├── img/                # Fotos e identidade visual já otimizadas
├── server.ps1          # Servidor local para preview (PowerShell)
└── build-img.ps1       # Script que regenera as imagens a partir dos originais
```

## Rodar localmente

Duplo clique em `server.ps1`, ou no terminal:

```powershell
.\server.ps1
```

Ou, se preferir, com o Python instalado:

```powershell
python -m http.server 8000
```

Depois abra `http://localhost:8000/` (ou a porta informada pelo `server.ps1`).

## Publicando no GitHub Pages

1. Crie um repositório e envie o código:

   ```powershell
   git init
   git add .
   git commit -m "Site institucional da Academia Pimenta Fitness"
   git branch -M main
   git remote add origin https://github.com/<usuario>/<repositorio>.git
   git push -u origin main
   ```

2. No GitHub: **Settings → Pages → Build and deployment → Branch: `main` / pasta `/root`**.

3. O site fica em `https://<usuario>.github.io/<repositorio>/`.

> As tags `canonical` e os metadados sociais já estão apontando para
> `https://ddesites.github.io/pimenta-fitness/`. Se o repositório tiver outro nome ou
> outra conta, atualize esses valores nos 6 arquivos `.html` antes de publicar.

## Identidade visual

- **Cores:** vermelho `#D61F26`, preto/grafite, branco. Verde reservado só como microdetalhe.
- **Tipografia:** Anton para títulos (condensada, forte) e Barlow para texto corrido,
  carregadas via Google Fonts.
- **Animações:** discretas, via `IntersectionObserver`, com fallback de segurança — se o
  JavaScript falhar, todo o conteúdo continua visível.

## Acessibilidade

- Skip link para pular ao conteúdo
- Navegação por teclado e foco visível
- Labels reais nos campos do formulário e mensagens de confirmação
- Contraste adequado em texto, botões e estados de erro

## Itens a confirmar com a academia antes de divulgar o site

Estes pontos vieram de fontes públicas (Google, Instagram) e **ainda não foram
confirmados pela academia**. Vale revisar antes de divulgar amplamente:

- **"Há 11 anos"** — consta no hero, em um indicador e no rodapé. Origem: bio do
  Instagram. Se a data de fundação estiver diferente, o número aparece em 3 lugares.
- **Fotos e depoimentos** — é preciso ter a autorização de uso de imagem de quem aparece
  nas fotos e de quem escreveu os depoimentos.
- **Preços e valores** — não publicados de propósito. Os planos direcionam ao WhatsApp
  para a equipe informar o valor atual.
- **Horários e modalidades** — confirmar se a grade atual está igual à descrita.

## Contato

- **WhatsApp e telefone:** (61) 99234-1330
- **Endereço:** Av. Terceira Avenida, 33 — Lotes 1 a 8, Mansões Olinda,
  Águas Lindas de Goiás/GO — CEP 72915-549
- **Horários:** Seg a sex 6h–22h · Sáb 8h–12h · Dom fechado
- **Instagram:** [@academia_pimenta_fitness](https://www.instagram.com/academia_pimenta_fitness/)
- **Facebook:** [Pimenta Fitness](https://www.facebook.com/pimentafitness01)
