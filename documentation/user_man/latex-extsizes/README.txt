LaTeX class files vendored from CTAN "extsizes" (LPPL-1.3c).
Upstream: https://ctan.org/pkg/extsizes

Only extarticle.cls and size14.clo are bundled so build-pdfs.sh can pass Pandoc
"-V documentclass=extarticle" and 14 pt body text without requiring a full
texlive-latex-extra install on CI hosts.

extarticle normally loads exscale.sty when present; our copy uses \IfFileExists so
minimal TinyTeX installs work without the full latex metapackage. CI installs
texlive-latex-base so exscale is available there.
