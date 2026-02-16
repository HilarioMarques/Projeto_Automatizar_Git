#!/bin/bash

PASTA_REPOSITORIO="$HOME/pastaTeste_automatizarGit"
MENSAGEM_COMMIT="commit automático"
BRANCH="main"

INTERVALO_COMMIT=30 #10 minutos em s
ULTIMO_COMMIT=0
HOUVE_ALTERACAO=false

cd "$PASTA_REPOSITORIO" || exit 1

echo "Monitorando alterações em $PASTA_REPOSITORIO ..."
echo "Commits automáticos a cada 10 minutos, se houver mudanças"

inotifywait -m -r \
  --exclude '\.git' \
  -e modify \
  -e create \
  -e delete \
  "$PASTA_REPOSITORIO" |
while read -r caminho evento arquivo; do
    echo "Alteração detectada: $evento em $arquivo"
    HOUVE_ALTERACAO=true

    AGORA=$(date +%s)
    DIFERENCA=$((AGORA - ULTIMO_COMMIT))

    if [ "$HOUVE_ALTERACAO" = true ] && [ "$DIFERENCA" -ge "$INTERVALO_COMMIT" ]; then
        echo "Intervalo atingido. Commitando"

        git add .

        if git diff --cached --quiet; then
            echo "nenhuma mudança real para commit"
        else
            git commit -m "$MENSAGEM_COMMIT"
            git push -u origin "$BRANCH"
	    ULTIMO_COMMIT=$AGORA
	    HOUVE_ALTERACAO=false
	fi
    fi
done
