# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rich::Style do
  describe "#initialize" do
    it "creates a style with no attributes" do
      style = described_class.new
      expect(style.color).to be_nil
      expect(style.bgcolor).to be_nil
      expect(style.bold).to be_nil
    end

    it "creates a style with color" do
      style = described_class.new(color: "red")
      expect(style.color).to eq("red")
    end

    it "creates a style with multiple attributes" do
      style = described_class.new(color: "red", bold: true, italic: true)
      expect(style.color).to eq("red")
      expect(style.bold).to eq(true)
      expect(style.italic).to eq(true)
    end
  end

  describe "#==" do
    it "compares styles for equality" do
      style1 = described_class.new(color: "red", bold: true)
      style2 = described_class.new(color: "red", bold: true)
      style3 = described_class.new(color: "blue", bold: true)

      expect(style1).to eq(style2)
      expect(style1).not_to eq(style3)
    end
  end

  describe "#copy" do
    it "creates a copy with updated attributes" do
      original = described_class.new(color: "red", bold: true)
      copy = original.copy(color: "blue")

      expect(copy.color).to eq("blue")
      expect(copy.bold).to eq(true)
      expect(original.color).to eq("red") # Original unchanged
    end
  end

  describe ".combine" do
    it "combines two styles" do
      style1 = described_class.new(color: "red", bold: true)
      style2 = described_class.new(color: "blue", italic: true)
      
      combined = described_class.combine(style1, style2)
      
      expect(combined.color).to eq("blue") # style2 takes precedence
      expect(combined.bold).to eq(true)    # from style1
      expect(combined.italic).to eq(true)  # from style2
    end

    it "handles nil styles" do
      style = described_class.new(color: "red")
      
      expect(described_class.combine(nil, style)).to eq(style)
      expect(described_class.combine(style, nil)).to eq(style)
      expect(described_class.combine(nil, nil)).to be_nil
    end
  end

  describe ".parse" do
    it "parses color names" do
      style = described_class.parse("red")
      expect(style.color).to eq("red")
    end

    it "parses style attributes" do
      style = described_class.parse("bold red")
      expect(style.color).to eq("red")
      expect(style.bold).to eq(true)
    end

    it "parses background colors" do
      style = described_class.parse("red on blue")
      expect(style.color).to eq("red")
      expect(style.bgcolor).to eq("blue")
    end

    it "parses complex style strings" do
      style = described_class.parse("bold italic red on blue")
      expect(style.color).to eq("red")
      expect(style.bgcolor).to eq("blue")
      expect(style.bold).to eq(true)
      expect(style.italic).to eq(true)
    end

    it "returns nil for empty strings" do
      expect(described_class.parse("")).to be_nil
      expect(described_class.parse(nil)).to be_nil
    end
  end

  describe "#render" do
    it "renders text with ANSI codes" do
      style = described_class.new(color: "red", bold: true)
      result = style.render("Hello")
      
      expect(result).to include("Hello")
      expect(result).to include("\e[") # Contains ANSI escape codes
    end

    it "returns plain text for null style" do
      style = described_class.new
      result = style.render("Hello")
      expect(result).to eq("Hello")
    end
  end

  describe "#null?" do
    it "returns true for empty style" do
      style = described_class.new
      expect(style.null?).to eq(true)
    end

    it "returns false for style with attributes" do
      style = described_class.new(color: "red")
      expect(style.null?).to eq(false)
    end
  end
end