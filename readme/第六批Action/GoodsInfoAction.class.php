<?php
/**
 * 功能：商品详情
 * @author siht
 * 时间：2016-09-10
 */
class GoodsInfoAction extends BaseAction 
{
	public $goods_id;	//商品id
	public $sub_gid;   //子商品id

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->goods_id = I('goods_id'); //商品id
		$this->sub_gid = I('sub_gid'); //子商品id
	}
		
	public function run() {	
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}

		$where = "goods_id = ".$this->goods_id." and sub_gid = ".$this->sub_gid;
		$field = array('goods_id', 'sub_gid', 'goods_name', 'sub_gname', 'goods_tag', 'spec_id','price','store_count','sale_count','goods_desc','goods_image1', 'brand_id','suitable_crowd','dosage_forms','shelf_life','manufacturer', 
			'goods_image1_mid','goods_image2', 'goods_image2_mid','goods_image3', 'goods_image3_mid','goods_image4', 'goods_image4_mid','status');

		$goods_Info = M('Tgoods')->field($field)->where($where)->find();
		if(empty($goods_Info))
		{
			$resp_desc = "找不到此商品的详情";
			$this->returnError($resp_desc, '1004');
		}

		$this->returnSuccess("获取活动详情成功", $goods_Info);
	}
	
	private function check(){		
		if($this->goods_id == '')
		{
			return array('resp_desc'=>'商品id不能为空！');
			return false;
		}
		if($this->sub_gid == '')
		{
			return array('resp_desc'=>'子商品id不能为空！');
			return false;
		}
		return true;
	}	
}
?>
