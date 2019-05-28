pub mod redis;

pub trait Memory {
    fn write(&self, block_number: u64, key: &[u8], value: &[u8]);
    fn read(&self, key: &[u8]) -> Vec<u8>;
    fn get_block_data(&self) -> Vec<u8>;
}
