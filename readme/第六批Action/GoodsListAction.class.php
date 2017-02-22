<?php
/**
 * 功能 商品列表查询
 * @author siht
 * 时间：2016-09-07
 */
class GoodsListAction extends BaseAction 
{
	public $spec_id;		//商品类型
	public $key_words;		//搜索关键字

	public $current_page;   //当前页
	public $page_size;   //每页大小	
		

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->spec_id = I('spec_id'); //商品类型
		$this->key_words = I('key_words'); //搜索关键字

		$this->current_page = I('current_page'); //当前页
		$this->page_size = I('page_size'); //每页大小

	}
	public function run() {		
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}
		$todayTime = date('YmdHis');

		$where = "status = 0";
		
		if(isset($this->spec_id) && $this->spec_id !=''){
			$where .= " and spec_id = ".$this->spec_id; 
		}
		 /*if(isset($this->key_words) && $this->key_words !=''){	
			$where .= " and goods_name = ".$this->key_words;
		}*/
		
		$start = ($this->current_page -1) * $this->page_size;
		$field = array('goods_id', 'sub_gid', 'goods_name', 'sub_gname', 'goods_tag', 'price','goods_image1', 'goods_image1_mid');
		
		$goods_list = M('Tgoods')->field($field)->where($where)->limit("{$start},{$this->page_size}")->select();
		

		if(!empty($goods_list)){
			$resp_desc = "获取商品列表成功";
						
			$all_count = M('Tgoods')->where($where)->count();
			$page_info = array();
			$page_info['page_size'] = $this->page_size;
			$page_info['current_page'] = $this->current_page;
			$page_info['total_num'] = $all_count;	
			$page_info['total_page'] = ceil($all_count/$this->page_size);
								
			$this->returnSuccess($resp_desc, array('goods_list' => $goods_list, 'page_nav' => $page_info));
		}
		else
		{
			$this->returnError("无相关商品", '0000');
		}
	}
	
	private function check(){		
		if($this->current_page == '')
		{
			return array('resp_desc'=>'当前页不能为空！');
			return false;
		}
		if($this->page_size == '')
		{
			return array('resp_desc'=>'单页大小不能为空！');
			return false;
		}
		if($this->page_size <= 0)
		{
			return array('resp_desc'=>'单页大小必须大于0！');
			return false;
		}
		return true;
	}	
}
?>