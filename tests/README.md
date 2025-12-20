# Tests Directory

テストスイートの構成と実行方法について説明します。

## ディレクトリ構成

```
tests/
├── README.md                    # このファイル
├── lib/
│   └── helpers.sh              # 共通テスト関数とユーティリティ
├── bash-config-test.sh         # bash 設定検証
├── cargo-test.sh               # Rust/Cargo インストール検証
└── integration-test.sh          # (今後) 統合テスト
```

## テスト実行方法

### 1. 単一テストの実行

```bash
# Cargo テストのみ
docker run --rm -it \
  -v "$(PWD):/workspace" \
  -w /workspace \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'chezmoi init --source=/workspace --destination=/root && \
           chezmoi apply --source=/workspace --destination=/root --force && \
           bash tests/cargo-test.sh'

# bash 設定テストのみ
docker run --rm -it \
  -v "$(PWD):/workspace" \
  -w /workspace \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'chezmoi init --source=/workspace --destination=/root && \
           chezmoi apply --source=/workspace --destination=/root --force && \
           bash tests/bash-config-test.sh'
```

### 2. すべてのテスト実行

```bash
docker run --rm -it \
  -v "$(PWD):/workspace" \
  -w /workspace \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'chezmoi init --source=/workspace --destination=/root && \
           chezmoi apply --source=/workspace --destination=/root --force && \
           for test in tests/*-test.sh; do bash "$test"; done'
```

### 3. ホスト環境でのテスト実行（Makefile）

```bash
# (今後) Makefile に test-cargo, test-bash などのターゲットを追加予定
make test-cargo
make test-bash
make test-all
```

## テスト共通関数（helpers.sh）

`tests/lib/helpers.sh` に定義されている共通関数：

| 関数 | 用途 | 例 |
|------|------|-----|
| `pass "メッセージ"` | テスト成功を記録 | `pass "cargo installed"` |
| `fail "メッセージ"` | テスト失敗でスクリプト終了 | `fail "rustc not found"` |
| `warn "メッセージ"` | 警告（継続実行） | `warn "Performance degraded"` |
| `assert_command "コマンド" "説明"` | コマンド成功確認 | `assert_command "cargo --version" "cargo works"` |
| `assert_executable "コマンド" "説明"` | 実行可能ファイル確認 | `assert_executable "rustc" "Rust installed"` |
| `assert_file_exists "/path" "説明"` | ファイル存在確認 | `assert_file_exists "$HOME/.bashrc"` |
| `assert_string_contains "文字列" "部分文字列" "説明"` | 文字列検索確認 | `assert_string_contains "$(rustc --version)" "rustc"` |
| `print_summary` | テスト結果サマリー表示 | `print_summary` |

## テスト追加時のガイドライン

新しいテストスクリプトを追加するときは：

1. **ファイル名**: `[機能]-test.sh` という命名規則（e.g., `cli-tools-test.sh`）

2. **テンプレート**:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/lib/helpers.sh"
   
   echo "=========================================="
   echo "Testing [機能]"
   echo "=========================================="
   
   # テスト内容
   assert_executable "command" "description"
   
   echo ""
   print_summary
   ```

3. **実行権限追加**:

   ```bash
   chmod +x tests/my-feature-test.sh
   ```

4. **CI に統合**: GitHub Actions や他の CI ツールから呼び出し

## テスト設計原則

- **独立**: 各テストスクリプトは独立して実行可能
- **簡潔**: 1 つのテストスクリプト = 1 つの機能/領域をテスト
- **再利用可能**: helpers.sh の関数を活用して共通部分を排除
- **出力明確**: PASS/FAIL/WARN を色分けして表示
- **冪等性**: 何度実行しても同じ結果

## 今後の拡張

- [ ] `cli-tools-test.sh`: Cargo でインストールされたツールの検証
- [ ] `integration-test.sh`: 複数ツール間の統合テスト
- [ ] `.github/workflows/test.yml`: CI/CD での自動テスト実行
- [ ] `tests/performance-test.sh`: 起動時間、メモリ使用量の測定
