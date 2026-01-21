#!/bin/bash
set -e
PROJECT_NAME=$1
[[ -z "$PROJECT_NAME" ]] && echo "用法: $0 <项目名称>" && exit 1

PROJECT_PATH=github.com/hsimwong/$PROJECT_NAME
git init 
go mod init $PROJECT_PATH
go mod tidy

mkdir -p cmd/$PROJECT_NAME internal
cat > cmd/$PROJECT_NAME/main.go << EOF
package main
import "log"
func main() { log.Println("Hello, $PROJECT_NAME!") }
EOF

cat >.gitignore <<'EOF'
bin/
*.exe
*.test
.DS_Store
vendor/
EOF

cat >Makefile <<EOF
build:
	mkdir -p bin
	go build -o bin/$PROJECT_NAME ./cmd/$PROJECT_NAME
run: build
	./bin/$PROJECT_NAME
clean:
	rm -rf bin/
	go clean
EOF
git branch -M master
git add .
git commit -m "First Commit
Established initial file structure"
git remote add origin git@github.com:HsimWong/$PROJECT_NAME.git


echo "✅ 项目 $PROJECT_NAME 创建完成！"
echo "📁 路径: $(pwd)"
echo "🚀 运行: make run"
