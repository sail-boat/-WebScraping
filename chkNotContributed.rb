require 'open-uri'
require 'nokogiri'

# スクレイピング習作
# 投稿日から削除対象アカウントか判定

# 参考
# Nokogiri http://d.hatena.ne.jp/takeR/20140901/1409604244
# Nokogiriその2 http://morizyun.github.io/blog/ruby-nokogiri-scraping-tutorial/#7
# Nokogiri その3 http://d.hatena.ne.jp/otn/20090509/p1

def is_deleteTarget(url)
  charset = nil

  begin
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
  rescue
    return false  # 404Errorなどは削除対象外
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  # 特定の場所を検索
  a = doc.search("//a[@class='status__relative-time u-url u-uid']").first

  # 投稿されてなければ削除対象
  return true if a.nil?

  t = a.text

  if /^*d$/ =~ t || /^*日$/ =~ t # 最新投稿日が1日以上前かどうか
    t = t.gsub(/d/, '')
    t = t.gsub(/日/, '')
    return false if /^\D+?$/ =~ t # 半角数字以外が混ざっていたら対象外
    return true if t.to_i >= 3  # 最新投稿日が3日以上前なら削除対象
  end

  return false
end

#### メイン処理
i_file = ARGV[0]
o_file = ARGV[1]
o_list = []

puts "削除対象判定開始"

# ファイルを読み込んで一行ずつ処理・削除対象か判定
File.open(i_file) do |file|
  file.each_line do |line|
    o_list.push(line.chomp) if is_deleteTarget(line.chomp)
  end
end

puts "削除対象判定終了・ファイル書き出し開始"

# 削除対象をファイルに書き出し
File.open(o_file, "w") do |f|
  for o in o_list do
    f.puts(o)
  end
end
