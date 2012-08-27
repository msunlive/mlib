package {
    import cn.msun.tick.Clock;
    import cn.msun.tick.Ticker;
    
    import flash.display.Sprite;
    
    public class mlib extends Sprite {
        public function mlib() {
            trace("hello world");
            Clock.init(stage);
            var ticker:Ticker = new Ticker();
			ticker.speedRate = 5;
            Clock.add(ticker);
            
            ticker.add(new TickTest());
        }
    }
}


import cn.msun.tick.ITick;

import flash.utils.getTimer;

class TickTest implements ITick {
    private var lastTime:uint = 0;
    
    public function tick(tickTime:uint, totalTime:uint, frame:uint):void {
        var nowTime:uint = getTimer();
        trace(nowTime, (nowTime - lastTime), "tickTime", tickTime, "totalTime", totalTime, "frame", frame);
        lastTime = nowTime;
    }
}
