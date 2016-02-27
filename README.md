# aws-destroyer
AWS練習用

AWS初心者がいろいろ触ってインスタンスの消し忘れを防ぐためのスクリプト

実行すると作ったものが色々吹っ飛ぶ。

# つかいかた
## 動作環境
- Ruby2.2以上
- bundler
- きれいなインターネット(proxyには対応していない）

```
$ gem install bundler #bundle command not foundのとき
$ git clone git@github.com:onodes/aws-destroyer.git
$ cd aws-destroyer
$ bundle install
$ cp aws-accounts.json.sample aws-accounts.json
$ vim aws-accounts.json #IAMからACCESS_IDとSECRET_KEYを取ってきて書き込む。消したいリージョンを入れる。例:ap-northeast-1
$ ruby aws-destroyer.rb
```
