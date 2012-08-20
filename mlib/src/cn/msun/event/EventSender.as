package cn.msun.event {
    import flash.utils.Dictionary;
    import cn.msun.core.mlib_internal;
    use namespace mlib_internal;
    
    /**
     * 等同原生EventDispatcher。
     * 使用对象池
     * 添加了removeListeners
     * @author Msun
     */
    public class EventSender {
        private var eventListeners:Dictionary = new Dictionary(true);
        private var remainingListeners:Vector.<Function> = new <Function>[];
        private static var bubbleChainPool:Vector.<IBubble> = new <IBubble>[];
        
        public function EventSender() {
        }
        
        /**
         * @param type
         * @param listener
         */
        public function addListener(type:String, listener:Function):void {
            var listeners:Vector.<Function> = eventListeners[type];
            
            if(listeners == null)
                eventListeners[type] = new <Function>[listener];
            else if(listeners.indexOf(listener) == -1)
                listeners.push(listener);
        }
        
        public function removeListener(type:String, listener:Function):void {
            var listeners:Vector.<Function> = eventListeners[type];
            
            if(listeners && listener.length > 0) {
                var numListeners:int = listeners.length;
                var removed:Boolean = false;
                
                for(var i:int = 0; i < numListeners; ++i) {
                    if(listeners[i] != listener) {
                        remainingListeners.push(listeners[i]);
                        removed = true;
                    }
                }
                
                if(removed) {
                    eventListeners[type] = remainingListeners;
                    //重复利用
                    remainingListeners = listeners;
                    remainingListeners.length = 0;
                }
            }
        }
        
        public function removeListeners(type:String = null):void {
            if(type && eventListeners)
                delete eventListeners[type];
            else
                eventListeners = new Dictionary(true);
        }
        
        public function sendEvent(event:Event):void {
            var bubbles:Boolean = event.bubbles;
            
            if(bubbles || hasEventListener(event.type)) {
                var previousTarget:EventSender = event.target;
                event.setTarget(this);
                
                if(bubbles && this is IBubble)
                    bubble(event);
                else
                    invoke(event);
                
                if(previousTarget)
                    event.setTarget(previousTarget);
            }
        }
        
        private function invoke(event:Event):Boolean {
            var listeners:Vector.<Function> = eventListeners[event.type];
            var numListeners:int = listeners ? listeners.length : 0;
            
            if(numListeners) {
                event.setCurrentTarget(this);
                var listener:Function;
                var numArgs:int;
                
                for(var i:int = 0; i < numListeners; ++i) {
                    listener = listeners[i] as Function;
                    numArgs = listener.length;
                    
                    if(numArgs == 0)
                        listener();
                    else if(numArgs == 1)
                        listener(event);
                    else
                        listener(event, event.data);
                    
                    //当前监听者如果设置了stopsImmediatePropagation则立刻stop
                    if(event.stopsImmediatePropagation)
                        return true;
                }
                
                //所有监听者收到事件后再stop
                return event.stopsPropagation;
            } else {
                return false;
            }
        }
        
        private function bubble(event:Event):void {
            var chain:Vector.<EventSender>;
            var element:IBubble = this as IBubble;
            var length:int = 1;
            
            //从池中取或者new
            if(bubbleChainPool.length > 0) {
                chain = bubbleChainPool.pop();
                chain[0] = element;
            } else
                chain = new <EventSender>[element];
            
            while(element = element.parent)
                chain[length++] = element;
            
            for(var i:int = 0; i < length; ++i) {
                var stopPropagation:Boolean = chain[i].invoke(event);
                
                if(stopPropagation)
                    break;
            }
            
            //重用
            chain.length = 0;
            bubbleChainPool.push(chain);
        }
        
        public function sendEventWith(type:String, bubbles:Boolean = false, data:Object = null):void {
            if(bubbles || hasEventListener(type)) {
                var event:Event = Event.fromPool(type, bubbles, data);
                sendEvent(event);
                Event.toPool(event);
            }
        }
        
        public function hasEventListener(type:String):Boolean {
            var listeners:Vector.<Function> = eventListeners[type];
            return listeners ? listeners.length != 0 : false;
        }
    }
}
