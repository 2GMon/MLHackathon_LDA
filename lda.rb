# Copyright (c) 2014 Takaaki TSUJIMOTO

class LDAWordList
  attr_reader :list, :v

  def initialize
    @list = []
    @v = 0
  end

  def include?(lda_word)
    @list.each do |w|
      if w.word == lda_word.word
        return true
      end
    end
    false
  end

  def add_word(lda_word)
    if !include?(lda_word)
      @v += 1
    end
      @list << lda_word
  end

  def get_n_wt(w, t)
    n_wt = 0
    @list.each do |word|
      if word.topic == t && word.word == w
        n_wt += 1
      end
    end
    n_wt
  end

  def get_n_t(t)
    n_t = 0
    @list.each do |word|
      if word.topic == t
        n_t += 1
      end
    end
    n_t
  end

  def get_word_belongs_to_topic(t)
    w_list = []
    @list.each do |word|
      pr = word.get_p
      if t == pr.index(pr.max)
        w_list << word.word
      end
    end
    puts w_list.join(", ")
  end
end

class LDAWord
  attr_accessor :word, :topic, :times

  def initialize(word, k)
    @word = word
    @topic = rand(k)
    @times = Array.new(k)
    k.times do |i|
      @times[i] = 0
    end
  end

  def get_p
    p = Array.new(times.size)
    sum = times.reduce(:+)
    times.each_with_index do |time, i|
      p[i] = time.to_f / sum
    end
    p
  end
end

class LDATextList
  attr_accessor :list

  def initialize
    @list = []
  end
end

class LDAText
  attr_accessor :word_list

  def initialize
    @word_list = []
  end

  def add_word(lda_word)
    @word_list << lda_word
  end

  def get_n_td(t)
    n_td = 0
    @word_list.each do |word|
      if word.topic == t
        n_td += 1
      end
    end
    n_td
  end

  def get_p
    p = Array.new(@word_list[0].times.size)
    p.size.times do |i|
      p[i] = 0
    end
    @word_list.each do |w|
      w_p = w.get_p
      p.size.times do |i|
        if w_p[i].nan?
          p[i] += 0
        else
          p[i] += w_p[i]
        end
      end
    end
    p
  end

  def get_topic
    pr = get_p
    pr.index(pr.max)
  end
end

def read_file(file_name)
  data = []
  File.open(file_name) do |f|
    f.each do |line|
      if !(/^doc/ =~ line)
        line = line.chomp.split(",")
        data << line
      end
    end
  end
  data
end

def sampling(t, w, d)
  n_td = d.get_n_td(t)
end


k = 5
a = k / 10.0
b = 0.1

data = read_file("./in1_small.csv")

lda_text_list = LDATextList.new
lda_word_list = LDAWordList.new
data.each do |d|
  d[2].to_i.times do
    lda_word =  LDAWord.new(d[1], k)
    lda_word_list.add_word(lda_word)

    # 文章がまだ存在しない時
    if lda_text_list.list.size <= d[0].to_i - 1
      lda_text = LDAText.new
      lda_text.add_word(lda_word)
      lda_text_list.list << lda_text
    else
      lda_text = lda_text_list.list[d[0].to_i - 1]
      lda_text.add_word(lda_word)
      lda_text_list.list[d[0].to_i - 1] = lda_text
    end
  end
end

50.times do |iter|
  puts "iter #{sprintf("%2d", iter + 1)}"
  lda_text_list.list.each do |text|
    text.word_list.each do |lda_word|
      # K面サイコロを作る
      p = Array.new(k)
      sum = 0
      k.times do |i|
        p[i] = (a + text.get_n_td(k)) * (b + lda_word_list.get_n_wt(lda_word.word, k)) / (b * lda_word_list.v + lda_word_list.get_n_t(k))
        sum += p[i]
      end
      rand_result = rand(0..sum)
      k.times do |i|
        rand_result -= p[i]
        if rand_result <= 0
          lda_word.topic = i
          lda_word.times[i] += 1
          break
        end
      end
    end
  end
end

k.times do |i|
  lda_word_list.get_word_belongs_to_topic(i)
end
