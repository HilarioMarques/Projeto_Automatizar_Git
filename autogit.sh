#!/bin/bash

PASTA_REPOSITORIO="$HOME/pastaTeste_automatizarGit"
MENSAGEM_COMMIT="commit automático"
BRANCH="main"

INTERVALO_COMMIT=30 #10 minutos em s
HOUVE_ALTERACAO=false

cd "$PASTA_REPOSITORIO" || exit 1

echo "Monitorando alterações em $PASTA_REPOSITORIO ..."
echo "Commits automáticos a cada 10 minutos, se houver mudanças"

while read -r caminho evento arquivo; do
    echo "Alteração detectada: $evento em $arquivo"
    HOUVE_ALTERACAO=true
done < <(
    inotifywait -m -r \
        --exclude '\.git' \
        -e modify \
        -e create \
        -e delete \
        "$PASTA_REPOSITORIO"
) &

while true; do
    sleep "$INTERVALO_COMMIT"

    if [ "$HOUVE_ALTERACAO" = true ]; then
        echo "Intervalo atingido. Commitando"

        git add .

        if git diff --cached --quiet; then
            echo "nenhuma mudança real para commit"
        else
            git commit -m "$MENSAGEM_COMMIT"
            git push -u origin "$BRANCH"
	fi

        HOUVE_ALTERACAO=false
    else
        echo "Nenhuma alteração detectada"
    fi
done
