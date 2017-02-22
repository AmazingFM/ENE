<?php
/**
 * 功能  根据传入的goods_id列表查询商品；购物车，收藏夹用
 * @author siht
 * 时间：2016-09-10
 */
class GoodsArrayQueryAction extends BaseAction 
{
	public $goods_array;		//商品id_array:[{'goods_id':1,'sub_gid':2},{'goods_id':3,'sub_gid':4}]
	
	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->goods_array = I('goods_array'); 

	}
	public function run() {		
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}
	
		$array_goods = json_decode(htmlspecialchars_decode($this->goods_array),true);
		//补充商品信息
		for($i=0; $i < count($array_goods); ++$i)
		{
			$where = "goods_id = ".$array_goods[$i]['goods_id']." and sub_gid = ".$array_goods[$i]['sub_gid'];
			$goods_detail = M('Tgoods')->where($where)->find();
			if(empty($goods_detail))
			{
				$this->returnError("无相关商品", '7001');
			}
			$array_goods[$i]['price'] = $goods_detail['price'];
			$array_goods[$i]['store_count'] = $goods_detail['store_count'];
			$array_goods[$i]['sale_count'] = $goods_detail['sale_count'];
			$array_goods[$i]['goods_image1'] = $goods_detail['goods_image1'];
			$array_goods[$i]['goods_image1_mid'] = $goods_detail['goods_image1_mid'];
			$array_goods[$i]['goods_tag'] = $goods_detail['goods_tag'];
			$array_goods[$i]['status'] = $goods_detail['status'];
		}
		
		$this->returnSuccess($resp_desc, array('goods_array' => $array_goods));
		
	}
	
	private function check(){		
		if($this->goods_array == '')
		{
			return array('resp_desc'=>'商品id array不能为空！');
			return false;
		}
		
		return true;
	}	
}
?>