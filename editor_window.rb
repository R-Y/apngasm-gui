require 'rubygems'
gem 'gtk3'

require './frame_list.rb'
require './frame.rb'

class EditorWindow
  #attr_accessor preview, frame_list
  def initialize(width = 800, height = 600)
    builder = Gtk::Builder.new
    builder.add_from_file("layout.glade")


    $window_base = builder["editor_window"]
    $window_base.set_default_size(width, height)

    @preview = builder["preview_image"]

    @frame_list = FrameList.new

    # scrolled_windowを取得して一時的にBox作成
    # 最初からlayout.gradeにBoxを入れておくと手間が少しだけ減ります。
    @frame_list_scrolled_window = builder["frame_list_scrolled_window"]
    @frame_hbox = Gtk::HBox.new
    @frame_list_scrolled_window.add_with_viewport(@frame_hbox)

    @add_frame_button = builder["add_frame_button"]
    @add_frame_button.signal_connect('clicked') {
      dialog = Gtk::FileChooserDialog.new("Open File",
                                          $window_base,
                                          Gtk::FileChooser::ACTION_OPEN,
                                          nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
      filter = Gtk::FileFilter.new
      filter.name = "Img File"
      filter.add_pattern("*.png")
      dialog.add_filter(filter)
      if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
        # Get file
        frame = create_frame(dialog.filename)

        @frame_hbox.pack_start(frame, false, false, 10)
        $window_base.show_all
      end
      dialog.destroy
}
#    @add_frame_button.signal_connect('file-set') {
#      frame = Frame.new(@add_frame_button.filename)
#      
#      @frame_list.add(frame)
#      @preview.set_pixbuf(frame.pixbuf)

#      $window_base.show_all
#    }

    $window_base.signal_connect("destroy") do
      Gtk.main_quit
    end

    $window_base.show_all
    Gtk.main
  end

  # とりあえずやっつけでframe作成。
  # gladeで作っておけるかどうかは現在は不明です。
  def create_frame(filename)
    frame = Gtk::Frame.new
    img = Gtk::Image.new(filename)
    box = Gtk::VBox.new
    box.pack_start(img, false, false, 10)
    adjustment = Gtk::Adjustment.new(10, 1, 999, 1, 1, 0)
    spin = Gtk::SpinButton.new(adjustment, 1, 0)
    box.pack_start(spin, false, false, 10)
    frame.add(box)
    return frame
  end
end
