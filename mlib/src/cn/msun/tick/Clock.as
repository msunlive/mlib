package cn.msun.tick {
    import flash.utils.getTimer;
    import flash.display.Stage;
    import flash.events.Event;
    
    /**
     * 基于EnterFrame的tick发生器
     * 结合了FrameBase和TimeBase的优点
     *
     * 全局就一个Clock，用来监听EnterFrame计算tick
     * Ticker管理一组相关ITick，Ticker可以变速(改变FPS)
     *
     * @author Msun
     */
    public class Clock {
        public static const FPS:uint = 60;
        
        private static var tickers:Vector.<Ticker> = new <Ticker>[];
        private static var currentTime:uint = 0;
        private static var currentFrame:uint = 0;
        private static var tickTime:uint = 0;
        
        public static function init(stage:Stage):void {
            stage.frameRate = FPS;
            stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        //        private static var testTime:uint = 0;
        
        private static function enterFrameHandler(event:Event):void {
            if(Clock.currentTime == 0) {
                currentTime = getTimer();
                return;
            }
            
            var num:uint = tickers.length;
            var index:uint = 0;
            var i:uint = 0;
            var ticker:Ticker;
            
            var nowTime:uint = getTimer();
            tickTime = nowTime - currentTime;
            currentTime = nowTime;
            ++currentFrame;
            
            //            trace(nowTime, nowTime - testTime, currentFrame, "enterFrame-----------");
            //            testTime = nowTime;
            
            for(i = 0; i < num; ++i) {
                ticker = tickers[i];
                
                if(ticker) {
                    ticker.tick(tickTime, currentTime, currentFrame);
                    
                    //remove时只是将数组对应位置设为null，现在要将null移到尾部，在下边将删除
                    if(index != i) {
                        tickers[index] = ticker;
                        tickers[i] = null;
                    }
                    
                    ++index;
                }
            }
            
            if(index != i) {
                //有空洞,删除之
                num = tickers.length;
                
                //ticks可能变长了
                while(i < num) {
                    tickers[index++] = tickers[i++];
                }
                
                tickers.length = index;
            }
        }
        
        public static function add(ticker:Ticker):void {
            if(ticker && tickers.indexOf(ticker) < 0) {
                tickers.push(ticker);
            }
        }
        
        public static function remove(ticker:Ticker):void {
            if(ticker) {
                var index:int = tickers.indexOf(ticker);
                
                if(index >= 0) {
                    tickers[index] = null;
                }
            }
        }
    }
}
