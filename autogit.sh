#!/bin/bash

PASTA_REPOSITORIO="$HOME/pastaTeste_automatizarGit"
MENSAGEM_COMMIT="commit automático"
BRANCH="main"

cd "$PASTA_REPOSITORIO" || exit 1

echo "Monitorando alterações em $PASTA_REPOSITORIO ..."

inotifywait -m -r \
  --exclude '\.git' \
  -e modify \
  -e create \
  -e delete \
  "$PASTA_REPOSITORIO" |
while read -r caminho evento arquivo; do
    echo "Alteração detectada: $evento em $arquivo"
    sleep 1
    git add .

    if git diff --cached --quiet; then
        echo "nenhuma mudança real para commit"
        continue
    fi

    git commit -m "$MENSAGEM_COMMIT"
    git push -u origin "$BRANCH"
done
