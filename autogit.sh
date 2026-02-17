#!/bin/bash

PASTA_REPOSITORIO="$HOME/pastaTeste_automatizarGit"
MENSAGEM_COMMIT="commit automático"
BRANCH="main"

INTERVALO_COMMIT=300 #5 minutos em s
FLAG_ARQUIVO="/tmp/autogit_flag"
LOCK_FILE="/tmp/autogit.lock"

# -- LOCK --
if [ -f "$LOCK_FILE" ]; then
    echo "AutoGit já está rodando!"
    exit 1
fi

echo $$ > "$LOCK_FILE"

# ---- CLEANUP ----
cleanup() {
    echo "Encerrando AutoGit..."
    rm -f "$FLAG_ARQUIVO"
    rm -f "$LOCK_FILE"
    pkill -P $$ 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT


cd "$PASTA_REPOSITORIO" || exit 1

echo "Monitorando alterações em $PASTA_REPOSITORIO ..."
echo "Commits automáticos a cada 5 minutos, se houver mudanças"

rm -f "$FLAG_ARQUIVO"

inotifywait -m -r \
    --exclude '\.git' \
    -e modify \
    -e create \
    -e delete \
    "$PASTA_REPOSITORIO" |
while read -r caminho evento arquivo; do
    echo "Alteração detectada: $evento em $arquivo"
    touch "$FLAG_ARQUIVO"
done &

while true; do
    sleep "$INTERVALO_COMMIT"

    if [ -f "$FLAG_ARQUIVO" ]; then
        echo "Intervalo atingido. Commitando"

        git add .

        if git diff --cached --quiet; then
            echo "nenhuma mudança real para commit"
        else
            git commit -m "$MENSAGEM_COMMIT"
            git push -u origin "$BRANCH"
	fi

        rm -f "$FLAG_ARQUIVO"
    else
        echo "Nenhuma alteração detectada"
    fi
done
