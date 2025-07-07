# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rich::Progress do
  let(:console) { Rich::Console.new }
  let(:progress) { described_class.new(console: console) }

  describe "#initialize" do
    it "creates a progress tracker" do
      expect(progress.console).to eq(console)
      expect(progress.tasks).to be_empty
    end

    it "accepts custom options" do
      custom_progress = described_class.new(
        console: console,
        refresh_per_second: 20,
        speed_estimate_period: 60
      )
      expect(custom_progress.refresh_per_second).to eq(20)
      expect(custom_progress.speed_estimate_period).to eq(60)
    end
  end

  describe "#add_task" do
    it "adds a new task" do
      task_id = progress.add_task("Test Task", total: 100)
      expect(task_id).to be_a(Integer)
      expect(progress.tasks.length).to eq(1)
    end

    it "adds a task with custom options" do
      task_id = progress.add_task(
        "Custom Task",
        total: 50,
        completed: 10,
        visible: false
      )
      
      task = progress.tasks[task_id]
      expect(task.description).to eq("Custom Task")
      expect(task.total).to eq(50)
      expect(task.completed).to eq(10)
      expect(task.visible).to eq(false)
    end
  end

  describe "#update" do
    let(:task_id) { progress.add_task("Test Task", total: 100) }

    it "updates task progress" do
      progress.update(task_id, completed: 50)
      task = progress.tasks[task_id]
      expect(task.completed).to eq(50)
    end

    it "updates task description" do
      progress.update(task_id, description: "Updated Task")
      task = progress.tasks[task_id]
      expect(task.description).to eq("Updated Task")
    end

    it "advances task progress" do
      initial_completed = progress.tasks[task_id].completed
      progress.advance(task_id, 25)
      expect(progress.tasks[task_id].completed).to eq(initial_completed + 25)
    end
  end

  describe "#start and #stop" do
    it "starts and stops the progress tracker" do
      expect { progress.start }.not_to raise_error
      expect { progress.stop }.not_to raise_error
    end
  end

  describe "#track" do
    it "tracks an enumerable with block" do
      items = [1, 2, 3, 4, 5]
      results = []
      
      progress.track(items, description: "Processing") do |item|
        results << item * 2
      end
      
      expect(results).to eq([2, 4, 6, 8, 10])
    end

    it "tracks an enumerable without block" do
      items = [1, 2, 3]
      tracked = progress.track(items)
      expect(tracked.to_a).to eq([1, 2, 3])
    end
  end

  describe "Rich::Progress::Task" do
    let(:task) do
      Rich::Progress::Task.new(
        id: 1,
        description: "Test Task",
        total: 100,
        completed: 25
      )
    end

    describe "#percentage" do
      it "calculates percentage complete" do
        expect(task.percentage).to eq(25.0)
      end

      it "handles zero total" do
        zero_task = Rich::Progress::Task.new(id: 1, total: 0)
        expect(zero_task.percentage).to eq(0.0)
      end
    end

    describe "#remaining" do
      it "calculates remaining work" do
        expect(task.remaining).to eq(75)
      end
    end

    describe "#finished?" do
      it "returns false for incomplete task" do
        expect(task.finished?).to eq(false)
      end

      it "returns true for complete task" do
        complete_task = Rich::Progress::Task.new(
          id: 1,
          total: 100,
          completed: 100
        )
        expect(complete_task.finished?).to eq(true)
      end
    end

    describe "#speed" do
      it "calculates speed based on elapsed time" do
        task.instance_variable_set(:@start_time, Time.now - 2)
        expect(task.speed).to be >= 0
      end
    end

    describe "#eta" do
      it "estimates time to completion" do
        task.instance_variable_set(:@start_time, Time.now - 1)
        eta = task.eta
        expect(eta).to be_a(Numeric)
      end
    end
  end

  describe "progress bar rendering" do
    let(:console) { Rich::Console.new }
    let(:options) { Rich::RenderOptions.new(max_width: 80) }

    it "renders progress bars to segments" do
      progress.add_task("Test", total: 100, completed: 50)
      segments = progress.__rich_console__(console, options)
      
      expect(segments).to be_an(Array)
      expect(segments).not_to be_empty
    end
  end

  describe "progress columns" do
    it "supports different column types" do
      columns = [
        Rich::Progress::TextColumn.new("[progress.description]{task.description}"),
        Rich::Progress::BarColumn.new,
        Rich::Progress::PercentageColumn.new,
        Rich::Progress::TimeRemainingColumn.new
      ]
      
      custom_progress = described_class.new(console: console, columns: columns)
      expect(custom_progress.columns.length).to eq(4)
    end
  end
end