require 'open-uri'
require 'nokogiri'

# 運動施設・自習施設が開館しているかチェック
# スクレイピングを行う

# アクアーレ長岡 開館チェック
def is_open_aquare?
	url = "https://www.aquarenagaoka.or.jp/"
	charset = nil

	begin
		html = open(url) do |f|
			charset = f.charset # 文字種別
			f.read # htmlを読み込んで変数htmlに返す
		end
	rescue
		return false # ページを開けなかったら閉館扱い
	end

	# htmlをパース(解析)してオブジェクトを生成
	doc = Nokogiri::HTML.parse(html, nil, charset)

	# 特定の場所を検索
	html_aquare = doc.search("//div[@class='kyukanbi']/div").first
	text_aquare = html_aquare.inner_html

	# 今日日付を取得、加工
	today = Date.today.strftime("%-m月%-d日")

	# 休館日リストに今日日付が有るかチェック
	return true if text_aquare.index(today).nil?
	return false
end

# みしま体育館 開館情報ダウンロード
def download_mishima?
	url="http://niigata-bs.sakura.ne.jp/si/mishima/?post_type=news"	
	charset = nil

	begin
		html = open(url) do |f|
			charset = f.charset # 文字種別
			f.read # htmlを読み込んで変数htmlに返す
		end
	rescue
		return false # ページを開けなかったら閉館扱い
	end

	# htmlをパース(解析)してオブジェクトを生成
	doc = Nokogiri::HTML.parse(html, nil, charset)

	# 特定の場所を検索
	html_mishima = doc.search("//img[ contains(@src,'png')]").first
	# 画像URLを取得
	image_mishima = html_mishima[:src]

	# ダウンロード
	filename = "mishima.png"
	open(image_mishima) do |file|
		open(filename, "w+b") do |out|
			out.write(file.read)
		  end
	end

	return true
end

# 長岡中央図書館 開館情報ダウンロード
def download_tosyokan?
	url="https://opac.lib.city.nagaoka.niigata.jp/jishuu.pdf"

	# ダウンロード
	filename = "tosyokan.pdf"
	open(url) do |file|
		open(filename, "w+b") do |out|
			out.write(file.read)
		  end
	end

	return true
end

# メイン処理
puts "処理開始"

## アクアーレ長岡
print "アクアーレ長岡 :" 
if is_open_aquare? then
	puts "open"
else
	puts "close"
end

## みしま体育館
print "みしま体育館 :"
if download_mishima? then
	puts "ダウンロード完了"
else
	puts "ダウンロードエラー"
end

## 長岡中央図書館
print "長岡図書館 :"
if download_tosyokan? then
	puts "ダウンロード完了"
else
	puts "ダウンロードエラー"
end

puts "処理終了"
