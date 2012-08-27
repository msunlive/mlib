package cn.msun.tick {
    import cn.msun.event.Event;
    import cn.msun.event.EventSender;
    
    /**
     * 管理一组ITick，可变速(FPS)
     *
     * @author Msun
     */
    public class Ticker implements ITick {
        
        private var ticks:Vector.<ITick>;
        private var currentFrame:uint;
        private var currentTime:uint;
        private var lastCurrentTime:uint;
        private var _speedRate:Number;
        private var interval:Number;
        private var deltaTime:Number;
        
        public function Ticker() {
            currentFrame = 0;
            currentTime = 0;
            lastCurrentTime = 0;
            ticks = new <ITick>[];
            interval = 1000 / Clock.FPS;
            deltaTime = 0;
        }
        
        public function get speedRate():Number {
            return _speedRate;
        }
        
        /**
         * @param value 加速的速率，0.5=减速1倍, 3=加速3倍
         */
        public function set speedRate(value:Number):void {
            _speedRate = value;
            interval = 1000 / (_speedRate * Clock.FPS);
        }
        
        public function add(tick:ITick):void {
            if(tick && ticks.indexOf(tick) < 0) {
                ticks.push(tick);
                
                var es:EventSender = tick as EventSender;
                
                if(es) {
                    es.addListener(Event.REMOVE_FROM_TICKER, removeHandler);
                }
            }
        }
        
        public function remove(tick:ITick):void {
            if(tick) {
                var es:EventSender = tick as EventSender;
                
                if(es) {
                    es.removeListener(Event.REMOVE_FROM_TICKER, removeHandler);
                }
                
                var index:int = ticks.indexOf(tick);
                
                if(index >= 0) {
                    ticks[index] = null;
                }
            }
        }
        
        public function clear():void {
            for(var i:int = ticks.length; i >= 0; --i) {
                var es:EventSender = ticks.pop() as EventSender;
                
                if(es) {
                    es.removeListener(Event.REMOVE_FROM_TICKER, removeHandler);
                }
            }
        }
        
        public function tick(tickTime:uint, totalTime:uint, frame:uint):void {
            var num:uint = ticks.length;
            var tick:ITick;
            
            //计算时间差
            var frameTime:Number = deltaTime + tickTime;
            var numFrame:uint = 0;
            
            if(frameTime > interval) {
                //超过一帧    
                numFrame = frameTime / interval;
                deltaTime = frameTime - numFrame * interval;
            } else {
                numFrame = 0;
                deltaTime = frameTime;
            }
            
            if(num == 0 || numFrame == 0)
                return;
            
            while(numFrame-- > 0) {
                var index:uint = 0;
                var i:uint = 0;
                
                currentTime += interval;
                ++currentFrame;
                
                num = ticks.length;
                
                for(i = 0; i < num; ++i) {
                    tick = ticks[i];
                    
                    if(tick) {
                        tick.tick(currentTime - lastCurrentTime, currentTime, currentFrame);
                        
                        //remove时只是将数组对应位置设为null，现在要将null移到尾部，在下边将删除
                        if(index != i) {
                            ticks[index] = tick;
                            ticks[i] = null;
                        }
                        
                        ++index;
                    }
                }
                
                if(index != i) {
                    //有空洞,删除之
                    num = ticks.length;
                    
                    //ticks可能变长了
                    while(i < num) {
                        ticks[index++] = ticks[i++];
                    }
                    
                    ticks.length = index;
                }
                
                tickTime = 0;
                lastCurrentTime = currentTime;
            }
        
        }
        
        private function removeHandler(event:Event):void {
            remove(event.target as ITick);
        }
    }
}
