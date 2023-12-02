package funkin.states;

import funkin.objects.funkui.FunkCheckBox;
import funkin.objects.funkui.FunkUIContainer;
import funkin.objects.funkui.FunkButton;

class TestStateUI extends MusicBeatState {
    var container:FunkUIContainer;
    
    public function new() {
        super();
        
        container = new FunkUIContainer(100, 100, 800, 400);
        add(container);
        for (i in 0...8) {
            container.add(new FunkButton(10, 10 + 50 * i, "abcabc"));
        }

        for (i in 0...8) {
            container.add(new FunkCheckBox(200, 10 + 50 * i, "abcabc"));
        }
    }
}