# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rich::Table do
  let(:table) { described_class.new }

  describe "#initialize" do
    it "creates an empty table" do
      expect(table.columns).to be_empty
      expect(table.rows).to be_empty
    end

    it "accepts a title" do
      titled_table = described_class.new(title: "Test Table")
      expect(titled_table.title).to eq("Test Table")
    end

    it "accepts styling options" do
      styled_table = described_class.new(
        header_style: Rich::Style.new(color: "red"),
        border_style: Rich::Style.new(color: "blue")
      )
      expect(styled_table.header_style.color).to eq("red")
      expect(styled_table.border_style.color).to eq("blue")
    end
  end

  describe "#add_column" do
    it "adds a column with header" do
      table.add_column("Name")
      expect(table.columns.length).to eq(1)
      expect(table.columns.first.header).to eq("Name")
    end

    it "adds a column with styling" do
      style = Rich::Style.new(color: "green")
      table.add_column("Name", style: style)
      expect(table.columns.first.style).to eq(style)
    end

    it "adds a column with justify option" do
      table.add_column("Age", justify: "center")
      expect(table.columns.first.justify).to eq("center")
    end
  end

  describe "#add_row" do
    before do
      table.add_column("Name")
      table.add_column("Age")
    end

    it "adds a row with values" do
      table.add_row("Alice", 30)
      expect(table.rows.length).to eq(1)
      expect(table.rows.first.cells.length).to eq(2)
    end

    it "adds a row with styling" do
      style = Rich::Style.new(color: "yellow")
      table.add_row("Bob", 25, style: style)
      expect(table.rows.first.style).to eq(style)
    end
  end

  describe "#add_separator" do
    it "adds a separator row" do
      table.add_separator
      expect(table.rows.length).to eq(1)
      expect(table.rows.first.type).to eq(:separator)
    end
  end

  describe "#__rich_console__" do
    let(:console) { Rich::Console.new }
    let(:options) { Rich::RenderOptions.new(max_width: 80) }

    before do
      table.add_column("Name")
      table.add_column("Age")
      table.add_row("Alice", 30)
      table.add_row("Bob", 25)
    end

    it "renders table to segments" do
      segments = table.__rich_console__(console, options)
      expect(segments).to be_an(Array)
      expect(segments).not_to be_empty
    end

    it "includes table content in segments" do
      segments = table.__rich_console__(console, options)
      content = segments.map(&:text).join
      
      expect(content).to include("Name")
      expect(content).to include("Age")
      expect(content).to include("Alice")
      expect(content).to include("Bob")
    end
  end

  describe "border styles" do
    it "supports different border styles" do
      Rich::Table::BORDER_STYLES.each do |style_name, _|
        styled_table = described_class.new(border_style: style_name)
        expect(styled_table.border_style).to eq(style_name)
      end
    end
  end

  describe "column operations" do
    before do
      table.add_column("Name", width: 20)
      table.add_column("Age", justify: "center")
      table.add_column("City", no_wrap: true)
    end

    it "handles different column configurations" do
      expect(table.columns[0].width).to eq(20)
      expect(table.columns[1].justify).to eq("center")
      expect(table.columns[2].no_wrap).to eq(true)
    end
  end

  describe "row operations" do
    before do
      table.add_column("Name")
      table.add_column("Status")
    end

    it "handles rows with different cell types" do
      table.add_row("Alice", Rich::Text.new("Active", style: Rich::Style.new(color: "green")))
      table.add_row("Bob", "Inactive")
      
      expect(table.rows.length).to eq(2)
      expect(table.rows[0].cells[1]).to be_a(Rich::Text)
      expect(table.rows[1].cells[1]).to be_a(String)
    end
  end
end