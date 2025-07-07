# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rich::Console do
  let(:console) { described_class.new }

  describe "#initialize" do
    it "creates a console with default settings" do
      expect(console.width).to be_a(Integer)
      expect(console.height).to be_a(Integer)
      expect(console.color_system).to be_a(String)
    end

    it "accepts custom width and height" do
      custom_console = described_class.new(width: 100, height: 50)
      expect(custom_console.width).to eq(100)
      expect(custom_console.height).to eq(50)
    end
  end

  describe "#print" do
    it "prints simple text" do
      expect { console.print("Hello World") }.not_to raise_error
    end

    it "prints multiple objects" do
      expect { console.print("Hello", "World", sep: " ") }.not_to raise_error
    end

    it "handles renderable objects" do
      text = Rich::Text.new("Styled text", style: Rich::Style.new(color: "red"))
      expect { console.print(text) }.not_to raise_error
    end
  end

  describe "#size" do
    it "returns width and height as array" do
      size = console.size
      expect(size).to be_an(Array)
      expect(size.length).to eq(2)
      expect(size[0]).to be_a(Integer) # width
      expect(size[1]).to be_a(Integer) # height
    end
  end

  describe "#render" do
    it "renders text objects to segments" do
      text = Rich::Text.new("Hello")
      segments = console.render(text)
      expect(segments).to be_an(Array)
      expect(segments.first).to be_a(Rich::Segment)
    end
  end

  describe "#make_renderable" do
    it "converts string to Text object" do
      renderable = console.make_renderable("Hello")
      expect(renderable).to be_a(Rich::Text)
    end

    it "passes through renderable objects" do
      text = Rich::Text.new("Hello")
      result = console.make_renderable(text)
      expect(result).to eq(text)
    end
  end
end