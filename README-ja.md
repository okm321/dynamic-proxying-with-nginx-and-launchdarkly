# Dynamic Proxying with Nginx and LaunchDarkly

このリポジトリは、[LaunchDarkly](https://launchdarkly.com)を使用してNginxの`proxy_pass`ディレクティブを動的に変更するサンプル構成を提供します。LaunchDarklyの`String`タイプのフラグを使用して、Nginxのリクエストを異なるバックエンドにルーティングします。このセットアップは、[LaunchDarkly Nginxガイド](https://docs.launchdarkly.com/guides/sdk/nginx)と[LaunchDarkly Lua SDKリポジトリ](https://github.com/launchdarkly/lua-server-sdk)を参考にしています。

## 前提条件

- LaunchDarklyアカウントとSDKキー
- `proxy_pass`のターゲットを決定するために使用する、`String`タイプのLaunchDarklyフィーチャーフラグ

## 初めに

### 1. リポジトリをクローンする

以下のコマンドで、このリポジトリをローカル環境にクローンします。

```bash
git clone https://github.com/your-username/nginx-with-launchdarkly.git
cd nginx-with-launchdarkly
```

### 2. Dockerイメージをビルドする

提供されている`Dockerfile`を使ってDockerイメージをビルドします。

```bash
docker build -t nginx-with-launchdarkly .
```

### 3. Dockerコンテナを実行する

必要な環境変数を設定してDockerコンテナを実行します。必ず`"your-sdk-key"`と`"your-flag-key"`を実際のLaunchDarklyのSDKキーとフラグキーに置き換えてください。

```bash
docker run --rm -p 8080:80 -e LAUNCHDARKLY_SDK_KEY="your-sdk-key" -e LAUNCHDARKLY_FLAG_KEY="your-flag-key" nginx-with-launchdarkly
```

このコマンドでNginxが`localhost:8080`で起動します。`proxy_pass`のターゲットは、指定されたLaunchDarklyフラグの値によって決まります。

## 仕組み

この構成では、LaunchDarkly Lua SDKを使用してフィーチャーフラグの値を取得し、それに基づいてNginxの`proxy_pass`ディレクティブを動的に設定します。これにより、フラグの値に応じてリクエストを異なるバックエンドにルーティングすることができます。

1. Luaスクリプトが、提供されたSDKキーを使用してLaunchDarklyクライアントを初期化します。
2. リクエストが受信されると、指定されたフラグ（`LAUNCHDARKLY_FLAG_KEY`）をチェックし、その値に基づいて`proxy_pass`のターゲットを設定します。
3. フラグが設定されていないかエラーが発生した場合は、指定されたデフォルトのドメイン（`FALLBACK_DOMAIN`）が使用されます。

## 環境変数

- `LAUNCHDARKLY_SDK_KEY`: LaunchDarklyのSDKキー。SDKがLaunchDarklyと通信するために必要です。
- `LAUNCHDARKLY_FLAG_KEY`: `proxy_pass`のターゲットを決定するために使用するLaunchDarklyのフィーチャーフラグのキー。
- `FALLBACK_DOMAIN`（オプション）: フラグの評価が失敗した場合に使用されるデフォルトのドメイン。

## 参考資料

- [LaunchDarkly Nginxガイド](https://docs.launchdarkly.com/guides/sdk/nginx)
- [LaunchDarkly Lua SDKリポジトリ](https://github.com/launchdarkly/lua-server-sdk)

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。
