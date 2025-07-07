# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rich::Text do
  describe "#initialize" do
    it "creates text with plain string" do
      text = described_class.new("Hello World")
      expect(text.plain).to eq("Hello World")
      expect(text.spans).to be_empty
    end

    it "creates text with style" do
      style = Rich::Style.new(color: "red")
      text = described_class.new("Hello", style: style)
      expect(text.plain).to eq("Hello")
      expect(text.style).to eq(style)
    end

    it "creates text with end character" do
      text = described_class.new("Hello", end_str: "\n")
      expect(text.end_str).to eq("\n")
    end
  end

  describe "#length" do
    it "returns the length of the text" do
      text = described_class.new("Hello")
      expect(text.length).to eq(5)
    end
  end

  describe "#+" do
    it "concatenates two Text objects" do
      text1 = described_class.new("Hello")
      text2 = described_class.new(" World")
      
      combined = text1 + text2
      expect(combined.plain).to eq("Hello World")
    end

    it "concatenates Text with string" do
      text = described_class.new("Hello")
      combined = text + " World"
      
      expect(combined.plain).to eq("Hello World")
    end
  end

  describe "#stylize" do
    it "applies style to a range" do
      text = described_class.new("Hello World")
      style = Rich::Style.new(color: "red")
      
      text.stylize(0, 5, style)
      expect(text.spans).not_to be_empty
    end

    it "applies style using string range" do
      text = described_class.new("Hello World")
      style = Rich::Style.new(color: "red")
      
      text.stylize("Hello", style: style)
      expect(text.spans).not_to be_empty
    end
  end

  describe "#highlight_words" do
    it "highlights specific words" do
      text = described_class.new("Hello beautiful world")
      style = Rich::Style.new(color: "yellow", bgcolor: "red")
      
      text.highlight_words(["beautiful"], style: style)
      expect(text.spans).not_to be_empty
    end

    it "highlights multiple words" do
      text = described_class.new("Hello beautiful wonderful world")
      style = Rich::Style.new(color: "yellow")
      
      text.highlight_words(["beautiful", "wonderful"], style: style)
      expect(text.spans.length).to be >= 2
    end
  end

  describe "#highlight_regex" do
    it "highlights text matching regex" do
      text = described_class.new("Hello 123 World 456")
      style = Rich::Style.new(color: "cyan")
      
      text.highlight_regex(/\d+/, style: style)
      expect(text.spans).not_to be_empty
    end
  end

  describe ".from_markup" do
    it "creates text from markup string" do
      text = described_class.from_markup("[bold]Hello[/bold] World")
      expect(text.plain).to eq("Hello World")
      expect(text.spans).not_to be_empty
    end
  end

  describe "#__rich_console__" do
    let(:console) { Rich::Console.new }
    let(:options) { Rich::RenderOptions.new(max_width: 80) }

    it "renders text to segments" do
      text = described_class.new("Hello World")
      segments = text.__rich_console__(console, options)
      
      expect(segments).to be_an(Array)
      expect(segments.first).to be_a(Rich::Segment)
      expect(segments.first.text).to eq("Hello World")
    end

    it "renders styled text to segments" do
      style = Rich::Style.new(color: "red")
      text = described_class.new("Hello World", style: style)
      segments = text.__rich_console__(console, options)
      
      expect(segments.first.style).to eq(style)
    end
  end

  describe "#to_s" do
    it "returns the plain text" do
      text = described_class.new("Hello World")
      expect(text.to_s).to eq("Hello World")
    end
  end

  describe "#inspect" do
    it "returns a meaningful inspect string" do
      text = described_class.new("Hello")
      inspect_str = text.inspect
      
      expect(inspect_str).to include("Text")
      expect(inspect_str).to include("Hello")
    end
  end
end