pub mod redis;

pub trait Storage {
    fn write(&self, block_number: u64, key: &[u8], value: &[u8]);
    fn read(&self, key: &[u8]) -> Vec<u8>;
}