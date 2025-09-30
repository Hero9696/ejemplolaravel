import {
    Table,
    TableBody,
    TableCaption,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import AppLayout from '@/layouts/app-layout';
import { type BreadcrumbItem } from '@/types';
import { Head, Link, useForm, } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { route } from 'ziggy-js';


interface Product {
    id: number;
    name: string;
    description: string;
    stock: number;
    price: number;
}

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Products',
        href: '/products',
    },
];

export default function Index({ products }: { products: Product[] }) {
const {processing, delete: destroy}=useForm();

const handleDelete=(id: number)=>{
    if(confirm('Are you sure you want to delete this product')){
        destroy(route('products.destroy', id));
    }
}

    return (
        <AppLayout breadcrumbs={breadcrumbs}>
            <Head title="Products | list" />
            <div className="m-4">
                <Link href={route('products.create').toString()}>
                <Button className='mb-4'>
                    Create Product
                </Button>
                </Link>
                {products.length > 0 && (
                    <Table>
                        <TableCaption>
                            A list of your recent invoices.
                        </TableCaption>
                        <TableHeader>
                            <TableRow>
                                <TableHead className="w-[100px]">ID</TableHead>
                                <TableHead>Name</TableHead>
                                <TableHead>Description</TableHead>
                                <TableHead>Stock</TableHead>
                                <TableHead>Price</TableHead>
                                <TableHead className="text-right">
                                    Actions
                                </TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {products.map((product) => (
                                <TableRow key={product.id}>
                                    <TableCell className="font-medium">
                                        {product.id}
                                    </TableCell>
                                    <TableCell>{product.name}</TableCell>
                                    <TableCell>{product.description}</TableCell>
                                    <TableCell>{product.stock}</TableCell>
                                    <TableCell>{product.price}</TableCell>
                                    <TableCell className="text-right">
 <Link href={route('products.edit', product.id).toString()}>
                <Button className='mb-4'>
                    Edit Product
                </Button>
                </Link>
                <Button
                disabled={processing}
className='bg-red-500 hover:bg-red-700'
onClick={()=>handleDelete(product.id)}
                >Delete</Button>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                )}
            </div>
        </AppLayout>
    );
}
